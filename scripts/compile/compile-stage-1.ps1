#
# Copyright (c) .NET Foundation and contributors. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

. $PSScriptRoot\..\common\_common.ps1

header "Compiling stage1 dotnet using downloaded stage0 ..."
$StartPath = $env:PATH
$env:PATH = "$env:DOTNET_INSTALL_DIR\cli\bin;$StartPath"

_ "$RepoRoot\scripts\compile\compile-stage.ps1" @("$Tfm","$Rid","$Configuration","$Stage1Dir","$RepoRoot","$HostDir")

# Copy in the dotnet-restore script
cp "$RepoRoot\scripts\dotnet-restore.cmd" "$Stage1Dir\bin\dotnet-restore.cmd"

$env:PATH=$StartPath