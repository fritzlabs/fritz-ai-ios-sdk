import os
import glob
import zipfile
import logging
from invoke import task
import deploy_utils
import deploy_config

_logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)


@task
def apply_version(ctx, tag, optimistic=False):
    """Applies a version to all podspecs and .plist files.

    Args:
        optimistic: if the model podspecs should use the optimistic operator
    """
    new_version = tag
    models = deploy_config.MODEL_FRAMEWORKS.keys()

    for podspec in glob.glob("**/*.podspec", recursive=True):
        current_version = deploy_utils.get_current_version(podspec)

        if optimistic and any(model in podspec for model in models):
            deploy_utils.update_podspec(
                podspec,
                current_version,
                new_version,
                dependency_names=["FritzBase/Vision"],
            )
        elif "Fritz.podspec" in podspec:
            deploy_utils.update_podspec(
                podspec,
                current_version,
                new_version,
                dependency_names=list(models) if optimistic else [],
            )
        else:
            deploy_utils.update_podspec(podspec, current_version, new_version)

    deploy_utils.update_info_plists(new_version)


@task
def manual_update_core(ctx, tag):
    """Applies a version to the FritzBase and Fritz podspecs and .plist files.

    Dependencies not using the optimistic operator will be updated in the Fritz podspec.

    Args:
        tag: new version number
    """
    current_version = deploy_utils.get_current_version("Source/FritzCore.podspec")
    new_version = tag

    for repo in deploy_config.REPOS:
        deploy_utils.update_changelog(repo, new_version)

    for podspec in glob.glob("**/FritzBase.podspec", recursive=True):
        current_version = deploy_utils.get_current_version(podspec)
        deploy_utils.update_podspec(
            podspec, current_version, new_version, only_pinned=True
        )

    for podspec in glob.glob("**/Fritz.podspec", recursive=True):
        current_version = deploy_utils.get_current_version(podspec)
        deploy_utils.update_podspec(
            podspec, current_version, new_version, only_pinned=True
        )

    core_targets = [
        "Fritz",
        "FritzVision",
        "FritzCore",
        "FritzManagedModel",
        "CoreMLHelpers",
    ]

    for target in core_targets:
        path = f"Source/{target}/Info.plist"
        deploy_utils.update_info_plist(path, new_version)


@task
def manual_update_target(ctx, target, tag):
    """Update the version of a specific target.

    When updating a model, the optimistic operator will be automatically
    used for the FritzVision dependency.

    Args:
        target: name of target to update
        tag: new version number of target
    """
    new_version = tag

    for podspec in glob.glob(f"**/{target}.podspec", recursive=True):
        current_version = deploy_utils.get_current_version(podspec)
        deploy_utils.update_podspec(
            podspec, current_version, new_version, dependency_names=["FritzBase/Vision"]
        )
    path = f"Source/{target}/Info.plist"
    deploy_utils.update_info_plist(path, new_version)


@task
def update_version(ctx, version="patch", build_framework=False):
    """Update sdk version.

    Steps:
        - Check for clean branch
        - Pull latest master
        - Determine new version from current podspec file.
        - Update changelog, podspec, and Info.plist with new version number.
        - Commit with version changes.
        - push changes
        - tag new version appropriately.
        - Optionally run build for framework.
    """
    if deploy_utils.git_modified_files():
        _logger.error(
            "Branch must be clean before updating version spec. "
            "Clean up modified files and try again."
        )
        return

    # no push is a command line argument to not push a branch to a repo.
    _logger.info("Updating lastest master branch")
    ctx.run("git checkout master")
    ctx.run("git pull origin master")

    current_version = deploy_utils.get_current_version("FritzCore.podspec")
    new_version = deploy_utils.get_bumped_version(version, current_version)

    for repo in deploy_config.REPOS:
        deploy_utils.update_changelog(repo, new_version)

    for podspec in glob.glob("**/*.podspec", recursive=True):
        current_version = deploy_utils.get_current_version(podspec)
        deploy_utils.update_podspec(podspec, current_version, new_version)

    deploy_utils.update_info_plists(new_version)

    # commit and push changes.
    ctx.run('git commit -am "Bump to version {}"'.format(new_version))
    deploy_utils.push_branch()
    deploy_utils.create_git_tag(new_version)


@task(default=True)
def list_tasks(ctx):
    """Default: Lists all available tasks"""
    ctx.run("invoke --list")


@task
def clone(ctx, repo_name):
    repo_url = deploy_config.REPOS[repo_name]["repo_url"]
    with deploy_utils.cd(".."):
        os.system("git clone {url}".format(url=repo_url))


@task
def make(ctx, repo_name):
    deploy_utils.run_command(f"make {repo_name}")


@task
def add_and_commit(ctx, repo_name, sdk_version):
    folder = deploy_config.REPOS[repo_name]["framework_folder"]
    with deploy_utils.cd(folder):
        os.system("git add .")
        os.system('git commit -am "Bump to version {}"'.format(sdk_version))


@task
def make_docs_and_commit(ctx, repo_name, sdk_version, push=False):
    """Build docs, commit to docs repo

    Args:
        repo_name: Name of destination repository
        sdk_version: SDK version of docs.
        push: If True pushes docs commit.
    """
    folder = deploy_config.REPOS[repo_name]["framework_folder"]
    deploy_utils.run_command("make docs")
    with deploy_utils.cd(folder):
        os.system("git add .")
        os.system(f'git commit -am "Updating docs for version {sdk_version}"')
        if push:
            os.system("git push")


@task
def tag_and_push(ctx, repo_name, sdk_version):
    """Create and push a new tag"""
    folder = deploy_config.REPOS[repo_name]["framework_folder"]
    with deploy_utils.cd(folder):
        os.system(f'git tag -a {sdk_version} -m "Bump to version {sdk_version}"')
        os.system("git push")
        os.system("git push origin --tags")


@task
def create_release_resources(ctx, repo_name, sdk_version, upload=True):
    """Creates release resources, zipping frameworks and optionally uploading.

    Args:
        repo_name: Name of repository.
        sdk_version: Version of repo.
        upload: if true, uploads zip files to s3.
    """
    config = deploy_config.REPOS[repo_name]
    with deploy_utils.cd(config["framework_folder"]):
        os.system("git checkout {sdk_version}".format(sdk_version=sdk_version))
        for details in config["podspecs"]:
            podspec_name = details["podspec"]
            zip_name = os.path.splitext(podspec_name)[0] + ".zip"
            zip_file = zipfile.ZipFile(zip_name, "w", zipfile.ZIP_DEFLATED)
            for framework in details["bundled_frameworks"]:
                for root, dirs, files in os.walk(framework):
                    for filename in files:
                        zip_file.write(os.path.join(root, filename))

            zip_file.write("LICENSE.md")
            zip_file.close()
            if upload:
                deploy_utils.upload_to_s3_if_not_exists(details, zip_name)

        os.system("git checkout master")


@task
def get_changelog_section(ctx, repo_name, version):
    print(deploy_utils.get_changelog_section(repo_name, version))


@task
def update_changelogs(ctx, version):
    for repo in deploy_config.REPOS:
        deploy_utils.update_changelog(repo, version)


@task
def deploy_podspecs(ctx, repo_name, version):
    config = deploy_config.REPOS[repo_name]
    deploy_utils.run_command("pod repo update")

    with deploy_utils.cd(config["framework_folder"]):
        os.system(f"git checkout {version}")
        for details in config["podspecs"]:
            if details["pod_repo"] == "master":
                print(details)
                deploy_utils.push_to_public_cocoapods_repo(details)
                continue

            deploy_utils.push_to_private_cocoapods_repo(details)
