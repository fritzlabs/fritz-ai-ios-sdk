import re
import os
import glob
import pathlib
import time
import plistlib
import logging
import subprocess
from contextlib import contextmanager
import boto3
import botocore
import semver

_logger = logging.getLogger(__name__)


class InvalidVersionSpecification(Exception):
    """Raised if version type is not valid."""


MAX_COCOAPOD_RETRIES = 4

RELEASE_BUCKET_BY_ENV = {
    "local": "",
    "production": "",
}


@contextmanager
def cd(path):
    old_dir = os.getcwd()
    os.chdir(path)
    yield
    os.chdir(old_dir)


def run_command(cmd: str):
    """Run shell command.

    Args:
        cmd: Command to run
    """
    return subprocess.check_call(cmd, shell=True)


def get_current_version(filename: str) -> str:
    """Gets current version from podspec file.

    Args:
        filename: name of podspec file.

    Returns: semvar version in podspec
    """
    with open(filename, "r") as f:
        version_lines = [line for line in f if re.match(".*s.version += .*", line)]
        if len(version_lines) > 1:
            # The Fritz.podspec file shouldn't change for this to be a problem,
            # but this is definitely brittle. If it breaks often, we can figure
            # out a less hacky way.
            raise Exception(
                "Found multiple lines with version. " "There can only be one."
            )

    line = version_lines[0]
    match = re.match(".*'(.*)'.*", line)
    return match.groups(0)[0]


def get_changelog_section(repo_name: str, version: str):
    """Get changelog for a version.

    Args:
        version: version to get changelog message for.
    """
    changelog = f"deploy_resources/{repo_name}/CHANGELOG.md"
    with open(changelog) as f:
        lines = f.readlines()

    changelog_lines = []
    reading_section = False
    for i, line in enumerate(lines):
        if line.startswith(f"## [{version}]"):
            reading_section = True
            continue
        elif reading_section and line.startswith("## ["):
            reading_section = False
            break
        elif not reading_section:
            continue

        changelog_lines.append(line)

    return "".join(changelog_lines)


def push_to_private_cocoapods_repo(details: dict):
    run_command(
        f'pod repo push {details["pod_repo"]} ' f'{details["podspec"]} --sources=master'
    )


def push_to_public_cocoapods_repo(details: dict, retry_attempt: int = 0):
    version = get_current_version(details["podspec"])
    try:
        podspec_name = os.path.splitext(details["podspec"])[0]
        # Space at end of version string ensures that
        # beta versions are not matched.
        run_command(f"pod trunk info {podspec_name} | grep '{version} '")
        version_exists = True
    except subprocess.CalledProcessError:
        version_exists = False

    if version_exists:
        print(f'Version {version} already exists for {details["podspec"]}')
        return

    if details.get("update_repo_before"):
        run_command("pod repo update")

    print(f"Updating {podspec_name} {version}")

    # Flag to use if the pod has a dependency
    synchronous = "--synchronous" if details.get("synchronize") else ""

    try:
        run_command(
            f'pod trunk push {details["podspec"]} --allow-warnings {synchronous}'
        )
    except subprocess.CalledProcessError:
        if retry_attempt == MAX_COCOAPOD_RETRIES:
            raise

        wait_seconds = 90
        _logger.warning(
            f"Trunk push failed, waiting {wait_seconds:,}s before trying again"
        )
        time.sleep(wait_seconds)
        return push_to_public_cocoapods_repo(details, retry_attempt=retry_attempt + 1)
    if details.get("update_repo_after"):
        run_command("pod repo update")


def git_modified_files(unstaged=False):
    """Check for modified files on branch.

    Args:
        unstaged: if true, checks checks for unstaged files as well.

    Returns: True if modified, False otherwise
    """
    try:
        run_command("git diff-index --quiet HEAD --")
    except subprocess.CalledProcessError:
        return True

    if unstaged:
        try:
            run_command('test -z "$(git ls-files --exclude-standard --others)"')
        except subprocess.CalledProcessError:
            return True

    return False


def update_podspec(
    filename: str,
    current_version: str,
    new_version: str,
    dependency_names=[],
    only_pinned=False,
):
    """Updates a podspec with a new version.

    Args:
        filename: name of the podspec to update
        current_version: version to replace
        new_version: version to update with
        dependency_names: dependencies that should use an optimistc operator
        only_pinned: if versions using an optimistic operator should be ignored
    """
    _logger.info("Updating %s from %s -> %s", filename, current_version, new_version)

    final_lines = []
    with open(filename, "r") as f:
        for line in f:
            # Very hacky, but we pin OpenCV to 3.4.2 and I don't want to
            # update the OpenCV version
            if "OpenCV" in line:
                final_lines.append(line)
                continue

            version = f"'{current_version}'" if only_pinned else current_version
            version_match = fr"(~>\s)?{current_version}"
            if any(name in line for name in dependency_names) and "dependency" in line:
                optimistic_version = f"~> {new_version}"
                line = re.sub(version_match, optimistic_version, line)
            elif version in line:
                line = re.sub(version_match, new_version, line)
            elif "source" in line:
                # Also update the source version to always match.
                line = line.replace(current_version, new_version)
            final_lines.append(line)

    with open(filename, "w") as f:
        f.write("".join(final_lines))


def update_info_plist(path: str, new_version: str):
    """Update Info.plist files for all frameworks.

    Args:
        new_version: Version to update plist files with.
    """
    with open(path, "rb") as f:
        plist = plistlib.load(f)
        if "FritzSDKVersion" in plist:
            current_version = plist["FritzSDKVersion"]
        else:
            current_version = "0.0.0"
        plist["FritzSDKVersion"] = new_version

    _logger.info("Updating %s from %s -> %s", path, current_version, new_version)

    with open(path, "wb") as f:
        plistlib.dump(plist, f)


def update_info_plists(new_version: str):
    """Update Info.plist files for all frameworks.
    Args:
        new_version: Version to update plist files with.
    """
    for filename in glob.glob("Source/*/Info.plist"):
        update_info_plist(filename, new_version)


def update_changelog(repo_name: str, new_version: str):
    """Update CHANGELOG.md with user inputted updates for a specific repo.

    Args:
        repo_name: Repo to deploy.
        new_version: semver new version to update.
    """
    if not yes(f"\nUpdate {repo_name} Changelog file?"):
        _logger.info("Not updating Changelog.")
        return

    changes = []
    changes.append(input("[" + str(len(changes) + 1) + "] "))
    while yes("Add another note to CHANGELOG.md?"):
        changes.append(input("[" + str(len(changes) + 1) + "] "))

    template = [
        "",
        "## [{version}]({github_base}/releases/tag/{version})",
        "",
        *["{}. {}".format(i + 1, change) for i, change in enumerate(changes)],
        "",
    ]
    template = "\n".join(template).format(
        version=new_version, github_base=f"https://github.com/fritzlabs/{repo_name}"
    )
    changelog_path = f"deploy_resources/{repo_name}/CHANGELOG.md"
    with open(changelog_path) as f:
        lines = f.readlines()

    for i, line in enumerate(lines):
        if line == "---\n":
            lines = [*lines[: i + 1], template, *lines[i + 1 :]]
            break

    with open(changelog_path, "w") as f:
        f.write("".join(lines))


def create_git_tag(version: str, push: bool = True):
    cmd = f'git tag -a {version} -m "Cut new version {version}"'
    run_command(cmd)

    if push:
        run_command("git push --tags")


def push_branch():
    """Push current branch to remote."""
    run_command("git push --set-upstream origin " "$(git rev-parse --abbrev-ref HEAD)")


def yes(question: str):
    """Prompt user to input y[es]/n[o] to a yes or no question.

    Args:
        question: Question to answer

    Returns: True if yes, False if no.
    """
    answer = input(question + " (y/n): ").lower().strip()

    while answer not in ["y", "n", "yes", "no"]:
        print("Input yes or no")
        answer = input(question + "(y/n):").lower().strip()

    return answer.startswith("y")


def get_bumped_version(version_type, current_version):
    if version_type == "patch":
        new_version = semver.bump_patch(current_version)
    elif version_type == "minor":
        new_version = semver.bump_minor(current_version)
    elif version_type == "major":
        new_version = semver.bump_major(current_version)
    elif version_type == "prerelease":
        new_version = semver.bump_prerelease(current_version, token="beta")
    else:
        raise InvalidVersionSpecification(
            "Version must be 'patch', 'minor', or 'major'"
        )

    return new_version


def upload_to_s3_if_not_exists(deploy_config, zip_file):
    """Uplaods zip framework if version does not exist in S3.

    Args:
        deploy_config: config of framework.
        zip_file: Zip file to upload.
    """
    env = os.getenv("FRITZ_ENV", "local")
    zip_path = pathlib.Path(zip_file)

    bucket_name = RELEASE_BUCKET_BY_ENV[env]
    podspec_path = pathlib.Path(deploy_config["podspec"])
    target = podspec_path.stem
    current_version = get_current_version(str(podspec_path))
    key = f"{target}/{current_version}/{zip_path.name}"
    s3 = boto3.client("s3")
    try:
        s3.head_object(Bucket=bucket_name, Key=key)
        # if this code is reached, it means that able to successfully
        # HEAD object, no upload needed.
        _logger.info(f"{key} already exists. Not uploading.")
    except botocore.exceptions.ClientError as err:
        if not err.response["Error"]["Code"] == "404":
            raise

        _logger.info(f"Uploading {target}-{current_version} to {key}")
        with zip_path.open(mode="rb") as f:
            s3.upload_fileobj(f, bucket_name, key)
