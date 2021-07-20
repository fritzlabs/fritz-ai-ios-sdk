#!/usr/bin/env bash

set -e

echo "Building docs for version ${SDK_VERSION}"

inv make-docs-and-commit $FRITZ_DEPLOY_REPO $SDK_VERSION
