#!/usr/bin/env bash
#
# Copyright (c) .NET Foundation and contributors. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

# Set OFFLINE environment variable to build offline

set -e

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ "$SOURCE" != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

source "$DIR/../common/_common.sh"
source "$REPOROOT/scripts/build/generate-version.sh"

header "Building dotnet tools version $DOTNET_BUILD_VERSION - $CONFIGURATION"
header "Checking Pre-Reqs"

$REPOROOT/scripts/test/check-prereqs.sh

header "Restoring Tools and Packages"

if [ ! -z "$OFFLINE" ]; then
    info "Skipping Tools and Package Download: Offline build"
else
   $REPOROOT/scripts/obtain/install-tools.sh
    
   $REPOROOT/scripts/build/restore-packages.sh
fi

header "Compiling"
$REPOROOT/scripts/compile/compile.sh

# Skipping tests for centos
# tracked by issue - https://github.com/dotnet/corefx/issues/5066
if [ "$OSNAME" != "centos"  ]; then
    # Run tests on the stage2 output
    header "Testing stage2..."
    DOTNET_HOME=$STAGE2_DIR DOTNET_TOOLS=$STAGE2_DIR $REPOROOT/scripts/test/runtests.sh
else
    header "Skipping tests on CentOS due to corefx issue 5066"
fi

header "Validating Dependencies"
$REPOROOT/scripts/test/validate-dependencies.sh

header "Generating tarball"
$REPOROOT/scripts/package/package.sh

if [ ! -z "$NOPACKAGE" ]; then
    header "Generating Native Installer"
    $REPOROOT/scripts/package/package-native.sh
else
    header "Skipping packaging"
fi