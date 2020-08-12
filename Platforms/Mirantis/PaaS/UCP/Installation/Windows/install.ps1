#!/usr/bin/env pwsh
#
# This script is meant for quick & easy install on Windows via an elevated command prompt:
#
# PS>Invoke-WebRequest -Uri get.mirantis.com/install.ps1
# PS>Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
# PS>.\install.ps1
#
# To obtain explicit versions of the script, append version number after replacing
# '.' and '-' characters in version with '_':
#
# PS>Invoke-WebRequest -Uri https://get.mirantis.com/install_1_0_5.ps1 -o install.ps1
#
# For more usage information run:
#
# PS>Get-Help .\install.ps1
#
# Copyright Mirantis Inc
#

<#
.SYNOPSIS

Installs required binaries for UCP install

.DESCRIPTION

The install.ps1 script installs DockerEE and containerd
binaries and services to the local machine.

The script has inbuilt-defaults for everything and can be run
without specifying any values. Script parameters and env
variables can be used to overrule the default values.
Parameter values take precedence over env variables.
Both take precedence over inbuilt default values.

The script needs to be executed from an elevated command prompt.
Should you want to change the default daemon configs, you may
want to have the alternative configurations and the related 
collateral in-place before executing the script. For example
if you would like to enable TLS with docker, please make sure
that the certificates are stored appropriately and the daemon
configuration file is written before invoking the script.

.PARAMETER DownloadUrl
[Alternately specified by $Env:DOWNLOAD_URL]
Specify an alternative repository to download container runtime
packages. Please consult the Mirantis product installation
documentation for air-gapped installs to learn more about setting
up a repository mirror.

.PARAMETER Channel
[Alternately specified by $Env:CHANNEL]
Specifies the channel to be used for picking the binaries.
Examples of channels are: stable, test etc. Stable is used as
the default channel.

.PARAMETER DockerVersion
[Alternately specified by $Env:DOCKER_VERSION]
Specifies the version number for the DockerEE binaries to install.
Latest is used as the default version.

.PARAMETER ContainerdVersion
[Alternately specified by $Env:CONTAINERD_VERSION]
Specifies the version number for the containerd binaries to install
Latest is used as the default version.

.PARAMETER DryRun
If specified, list different steps that would be used
without actually invoking them.

.PARAMETER Uninstall
If specified, uninstalls all packages. This entails 
unregistering the corresponding services and removing paths
for the package from the registry.
All other script parameters (except DryRun and DestPath) are 
ignored if this switch is specified. Common parameters such
as -Verbose are still honored.

.PARAMETER Ver
Print version info for the script and exit

.PARAMETER NoServiceStarts
If specified, services are not started on successful install.
By default, all services installed by the script are
left in a running state before exit.

.PARAMETER DestPath
Path to the directory under which binaries will be installed.
By default, this path is %PROGRAMDATA%

.PARAMETER OfflinePackagesPath
The folder for airgap/offline scenarios. For use when the
offline or DownloadOnly parameters are specified. Used to
either save the downloaded packages for later offline use
or for pointing to previously downloaded packages for
offline install.

.PARAMETER Offline
Install packages in offline/airgap mode. By default the
current directory will be used to look for previously
downloaded packages. That can be overridden by using
the OfflinePackagesPath parameter.

.PARAMETER DownloadOnly
Download and save packages for later offline/airgap install

.PARAMETER EngineOnly
Skip all steps except those related to Docker EE engine

.INPUTS

None. You cannot pipe objects to install.ps1.

.OUTPUTS

None. install.ps1 does not generate any output.

.EXAMPLE

PS> .\install.ps1

.EXAMPLE

PS> .\install.ps1 -Verbose

.NOTES
1. In scenarios where you have existing installed software that has its own 
   copies of OpenSSL libraries, you may run into the following error:

OpenSSL error: error:0F06D065:common libcrypto routines:FIPS_mode_set:fips mode not supported

This is often hit if you have ming/mingw64 as a part of your PATH env
variable. To work around this, ensure that the offending software is
not on the PATH and run the script again.

2. The script supports airgap functionality by providing access to
   download packages while online as well as to install those selfsame
   packages while offline.

   For downloads, please ensure that the script has access to the internet.
   Use the -DownloadOnly parameter. By default the script will use the
   current directory to store the packages after download. This can be 
   changed by specifying the path explicitly with the -OfflinePackagesPath
   parameter.

   For offline/airgap install, please use the -Offline parameter. By default
   the script will look for pacakage in the current directory. This can be 
   changed by specifying the -OfflinePackagesPath parameter.

   While downloading using -DownloadOnly parameter, make sure that the
   download path is accessible to the script, especially if you run the
   script without administrative rights.
   
#>

# The following is required so that the script can be invoked with named
# parameters (e.g. -ContainerdVersion 1.3.4...). If a parameter is used;
# its type is checked by powershell - we give a higher precedence to the
# parameters specified this way vs. the same value specified by env vars.

# Parameters gotten at invocation time. Some of these values are "merged"
# with values specified by env vars - see reconcileParams. Others are
# used as-is.

[CmdletBinding(PositionalBinding=$FALSE)]
param (
        [string]$DownloadUrl,                # Pointer to CDN for the package zip files.
        [string]$Channel,                    #
        [string]$DockerVersion,              #
        [string]$ContainerdVersion,          #

        [switch]$DryRun,                     # Gives an overview of what would happen on invoking the script. Is
                                             # idempotent - can be run repeatedly without impacting system state.
        [switch]$Uninstall,                  # Uninstall all installed packages
        [switch]$Ver,                        # Print version Info and exit
        [switch]$NoServiceStarts,            # Do not start the services at the end. Useful if certificates need to be
                                             # used or config needs to be built before starting one or more daemons.
                                             # For example, script invoker may want to build docker config file before
                                             # starting the dockerd service.

        [string]$DestPath,                   # A folder to which all installs will be done. Currently there is no way
                                             # to specify the name of the leaf folder and they are hardcoded.
        [string]$OfflinePackagesPath,        # A folder for airgap/offline scenarios. If specified, will be used to save
                                             # and retrieve packages for this scenario.
        [switch]$Offline,                    # Install packages in offline/airgap mode
        [switch]$DownloadOnly,               # Download and save packages for later offline/airgap install
        [switch]$EngineOnly                  # Skip everything except DockerEE 
       )

$ErrorActionPreference="Stop"
$global:ProgressPreference = 'SilentlyContinue'

# Updated manually
New-Variable -Name 'SCRIPT_SEMVER_VERSION' -Value '1.0.11' -Option Constant

# Leave the value blank except when intending to make an external release
# in which case set the value to a small phrase about the release e.g.
# 'Beta Refresh for UCP 3.3.0'
New-Variable -Name 'PUBLISH_STRING' -Value 'UCP 3.3.0' -Option Constant

# Updated automatically by the CI pipeline
New-Variable -Name 'SCRIPT_COMMIT_SHA' -Value '9038f2d' -Option Constant

# Internal values[constants/variables]
$script:intgenUrl=''                         # The effective Url for the package - see function genUrlFromVersionAndChannel
$script:intDownloadUrl=''
$script:intChannel=''
$script:intDockerVersion=''
$script:intContainerdVersion=''
$script:intDestPath=''
$script:intOfflinePackagesPath=''

New-Variable -Name 'DOCKER_PKG_NAME' -Value 'docker' -Option Constant
New-Variable -Name 'CONTAINERD_PKG_NAME' -Value 'containerd' -Option Constant
New-Variable -Name 'DOCKER_SVC_NAME' -Value 'docker' -Option Constant
New-Variable -Name 'CONTAINERD_SVC_NAME' -Value 'containerd' -Option Constant
New-Variable -Name 'CONTAINERS_FEATURE_NOT_INSTALLED' -Value @"
Installing the containers feature. It is a prerequisite for containers on Windows and requires a reboot.
"@ -Option Constant

New-Variable -Name 'DEFAULT_DOWNLOAD_URL' -Value "https://repos.mirantis.com" -Option Constant
New-Variable -Name 'DEFAULT_CHANNEL' -Value 'stable' -Option Constant
New-Variable -Name 'DEFAULT_DOCKER_VERSION' -Value 'latest' -Option Constant
New-Variable -Name 'DEFAULT_CONTAINERD_VERSION' -Value 'latest' -Option Constant

New-Variable -Name 'DEFAULT_DEST_PATH' -Value "$env:ProgramFiles" -Option Constant

New-Variable -Name 'dockerExists' -Scope 'Script' -Value $FALSE
New-Variable -Name 'containerdExists' -Scope 'Script' -Value $FALSE
New-Variable -Name 'mustLogoff' -Scope 'Script' -Value $FALSE

New-Variable -Name 'initDockerVer' -Scope 'Script' -Value ''
New-Variable -Name 'initContainerdVer' -Scope 'Script' -Value ''
New-Variable -Name 'finalDockerVer' -Scope 'Script' -Value ''
New-Variable -Name 'finalContainerdVer' -Scope 'Script' -Value ''

New-Variable -Name 'EXIT_REBOOT_MESSAGE' -Value "Your machine needs to be rebooted now. Installed packages will not work without reboot." -Option Constant
New-Variable -Name 'EXIT_LOGOFF_MESSAGE' -Value "The system-wide PATH has been updated. To use docker.exe and other CLI tools, please logoff and logon to update your PATH." -Option Constant

# PortNumber, Type, In/Out/Inout
# Name of the generated rule will be "docker_[PortNumber]"
$allPorts = (2376,   "tcp", "in"), `
            (2377,   "tcp", "in"), `
            (4789,   "udp", "inout"), `
            (6443,   "tcp", "inout"), `   # kube
            (7946,   "tcp", "inout"), `
            (7946,   "udp", "inout"), `
            (10250,  "tcp", "in"), `      # kubelet HTTPS port
            (12376,  "udp", "inout")

# To ensure that we can overwrite the package binaries
# successfully,  we need  to  stop  the  corresponding 
# service. Sometimes  this can  impact to network  and
# cause failure  in download. To guard against  it, we
# download the packages first and saved their downloaded
# location for user later on.
$downloadedPackageLocation = @{}

function Default {
        param( [string]$cmdlineValue, [string]$envvarValue, [string]$defaultValue )
        $value=""
        if (![string]::IsNullOrWhiteSpace($cmdlineValue)) {
                $value=$cmdlineValue.Trim()
                return $value
        }

        if (![string]::IsNullOrWhiteSpace($envvarValue)) {
                $value=$envvarValue.Trim()
                return $value
        }

        # Use the default value no matter what it is
        $value="$defaultValue"
        return $value
}

function updateServicesInstallStatus {
        blank
        verboseLog "Checking state of existing services"
        if (Get-Service $DOCKER_SVC_NAME -ErrorAction SilentlyContinue) {
                verboseLog "Service $DOCKER_SVC_NAME exists"
                $script:dockerExists=$TRUE
        } else {
                verboseLog "Service $DOCKER_SVC_NAME does not exist"
        }

        if ($EngineOnly) {
                return
        }

        if (Get-Service $CONTAINERD_SVC_NAME -ErrorAction SilentlyContinue) {
                verboseLog "Service $CONTAINERD_SVC_NAME exists"
                $script:containerdExists=$TRUE
        } else {
                verboseLog "Service $CONTAINERD_SVC_NAME does not exist"
        }
}

function getServicesInstallStatus {
        updateServicesInstallStatus
}

function ensureExistingServicesStarted {
        blank
        if (-not $EngineOnly) {
                if ($script:containerdExists) {
                        if (-not $DryRun) {
                                Start-Service -Name $CONTAINERD_SVC_NAME
                        }
                        verboseLog "Started service $CONTAINERD_SVC_NAME"
                }
        }

        if ($script:dockerExists) {
                if (-not $DryRun) {
                        Start-Service -Name $DOCKER_SVC_NAME
                }
                verboseLog "Started service $DOCKER_SVC_NAME"
        }
        verboseLog "Ensured all services are started"
}

function ensureExistingServicesStopped {
        blank
        if ($script:dockerExists) {
                if (-not $DryRun) {
                        Stop-Service -Name $DOCKER_SVC_NAME -Force
                }
                verboseLog "Stopped service $DOCKER_SVC_NAME"
        }

        if ($EngineOnly) {
                verboseLog "Ensured any installed services are in a stopped state"
                return
        }

        if ($script:containerdExists) {
                if (-not $DryRun) {
                        Stop-Service -Name $CONTAINERD_SVC_NAME -Force
                }
                verboseLog "Stopped service $CONTAINERD_SVC_NAME"
        }
        verboseLog "Ensured any installed services are in a stopped state"
}

function blank {
        Write-Verbose ""
}

function verboseLog {
        Write-Verbose "$args"
}

function infoLog {
        Write-Information "$args"
}

function errorLog {
        Write-Error "$args"
}

function VerboseWithCheck {
        param($pfx, $sfx)
        if (![string]::IsNullOrWhiteSpace($sfx)) {
                verboseLog "$pfx`:$sfx"
        } else {
                verboseLog "$pfx`:[unspecified]"
        }
}

function downloadPackageToInstall {
        param($pkgname, $channel, $version)
        verboseLog "Downloading binaries for $pkgName"
        blank

        $downloadedPackageLocation["$pkgname"] = ""

        genUrlFromVersionAndChannel "$pkgname" "$channel" "$version"
        $downloadUrl = $script:genUrl

        if ($Offline) {
                # Offline install - files already available.
                # Verify and exit if offline files missing.
                $tempZipFilePath = Join-Path -Path "$script:intOfflinePackagesPath" -ChildPath "$pkgname.zip"
                if (-not (Test-Path $tempZipFilePath -PathType leaf)) {
                        errorLog "Offline install: zip file $pkgname.zip not found at expected path $tempZipFilePath"
                        exit
                }
        } else {
                if ($DownloadOnly) {
                        $tempZipFilePath = Join-Path -Path "$script:intOfflinePackagesPath" -ChildPath "$pkgname.zip"
                } else {
                        [string] $tempname = [System.Guid]::NewGuid()
                        $tempZipFilePath = Join-Path -Path "$script:intDestPath" -ChildPath "$tempname.zip"
                }

                "Downloading $pkgname zip into $tempZipFilePath from: $downloadUrl - this may take some time"
                Invoke-WebRequest "$downloadUrl" -UseBasicParsing -OutFile "$tempZipFilePath"
                "Download of package $pkgname finished"
        }

        verboseLog "Downloaded binaries for $pkgName to $tempZipFilePath"
        $downloadedPackageLocation["$pkgname"] = "$tempZipFilePath"
}

function downloadAllPackagesForInstall {
        downloadPackageToInstall "Docker"     "$script:intChannel" "$script:intDockerVersion"

        if ($EngineOnly) {
                return
        }

        downloadPackageToInstall "Containerd" "$script:intChannel" "$script:intContainerdVersion"
}

function genUrlFromVersionAndChannel {
        # All parameters below will always have a value due to defaults
        param($pkgname, $channel, $version)
        $script:genUrl = "$script:intDownloadUrl`/win`/static`/$channel`/x86_64`/$pkgname`-$version`.zip"

        # AWS is case sensitive and we use all lowers - ensure that.
        $script:genUrl = $script:genUrl.ToLower()

        verboseLog "genUrl: $pkgname $channel $version $script:genUrl"
}
function openPortWorker {
        param ($cmd)
        Invoke-Expression $cmd|Out-Null
        if ($LASTEXITCODE -ne 0) {
                Write-Warning "$cmd failed with $LASTEXITCODE. Please try to open firewall port manually"
        } else {
                verboseLog "Opened port successfully"
        }
}

# Failures opening ports are non-fatal but must be detected and logged
function openPorts {
        foreach ($curPort in $allPorts)
        {
                $curPortNumber = $curPort[0]
                $curPortProtocol = $curPort[1]
                $curPortDirection = $curPort[2]

                if (-not $DryRun) {
                        if ($curPortDirection -eq "in" -or $curPortDirection -eq "inout") {
                                verboseLog "Opening IN port $curPortNumber[$curPortDirection] for $curPortProtocol"
                                $cmd = "netsh advfirewall firewall add rule name=`"docker`_$curPortNumber`_in`" dir=in action=allow protocol=$curPortProtocol localport=$curPortNumber"
                                openPortWorker "$cmd"
                        }

                        if ($curPortDirection -eq "out" -or $curPortDirection -eq "inout") {
                                verboseLog "Opening OUT port $curPortNumber[$curPortDirection] for $curPortProtocol"
                                $cmd = "netsh advfirewall firewall add rule name=`"docker`_$curPortNumber`_out`" dir=out action=allow protocol=$curPortProtocol localport=$curPortNumber"
                                openPortWorker "$cmd"
                        }
                } else {
                        verboseLog "Opening port $curPortNumber[$curPortDirection] for $curPortProtocol"
                }
        }
}

function updatedDryRunPkgVer {
        param ($pkgname, $tempZipFilePath)

        $pkgname = $pkgname.ToLower()
        $parent = [System.IO.Path]::GetTempPath()
        [string] $name = [System.Guid]::NewGuid()
        $tempDir = Join-Path $parent $name
        New-Item -ItemType Directory -Path $tempDir|Out-Null
        Expand-Archive -Path "$tempZipFilePath" -DestinationPath "$tempDir" -Force

        # The following is intentionally fatal - we do want
        # to detect any packaging issues etc. immediately.
        if ($pkgname -eq "docker") {
                $tmp = & "$tempDir`\Docker`\docker.exe" -v|Out-String
                if ($LASTEXITCODE -ne 0) {
                        errorLog "$cmd returned $LASTEXITCODE"
                        exit
                }
                $tmp = $tmp.Trim().split('	 ',3)
                $script:finalDockerVer = $tmp[2]
        } elseif ($pkgname -eq "containerd") {
                $tmp = & "$tempDir`\Containerd`\ctr.exe" -v|Out-String
                if ($LASTEXITCODE -ne 0) {
                        errorLog "$cmd returned $LASTEXITCODE"
                        exit
                }
                $tmp = $tmp.Trim().split('	 ',3)
                $script:finalContainerdVer = $tmp[2].Substring(1)
        }

        Remove-Item -Recurse -Force "$tempDir"
}
        
function workerFunc {
        param($pkgname)

        $tempZipFilePath = $downloadedPackageLocation["$pkgname"]
        "Using preloaded zip File $tempZipFilePath for installing package $pkgname"
        if (-not $DryRun) {
                verboseLog "Expanding archive $tempZipFilePath into $script:intDestPath"
                Expand-Archive -Path "$tempZipFilePath" -DestinationPath "$script:intDestPath" -Force
        } else {
                updatedDryRunPkgVer $pkgname $tempZipFilePath
        }

        if (-not $Offline) {
                verboseLog "Removing temporary Zip File $tempZipFilePath"
                Remove-Item -Force "$tempZipFilePath"
        }
}

function ensurePathNotExist {
        param ($pathtoremove)
        $pathtoremove = $pathtoremove.ToLower().Trim().Trim('"').TrimStart('"')

        verboseLog "Ensure $pathtoremove is removed from PATH, if present"

        $newPath = ""
        $notChanged = $TRUE

        $oldpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
        ForEach ($curPathOrig in $oldpath.split(";")) { 

                $curPath = $curPathOrig.ToLower().Trim().Trim('"').TrimStart('"')

                if ($curPath -ne $pathtoremove) {
                        # Add it to new path
                        $newPath += $curPathOrig + ';'
                } else {
                        # Do not add - set a flag.
                        $notChanged = $FALSE
             }
        }

        if (-not $notChanged) {
                verboseLog "Removing $pathtoremove from PATH"
                if (-not $DryRun) {
                        Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newpath
                }
        } else {
                verboseLog "$pathtoremove not found in PATH"
        }
}

function checkPathExists {
        param ($oldpath, $pathToCheck)
        $oldpath = $oldpath.ToLower().Trim()
        $pathToCheck = $pathToCheck.ToLower().Trim()

        # Present at the very end without any separator
        if ($oldpath.endsWith($pathToCheck)) {
                return $TRUE
        }

        if ($oldpath.contains("$pathToCheck`;")) {
                return $TRUE
        }

        if ($oldpath.contains("$pathToCheck`"")) {
                return $TRUE
        }

        return $FALSE
}

# In case a service already existed, unregister and register it
# so that we always have a consistent state at the end.
# Verified (code and testing) that --unregister-service does not
# cause any existing windows events to be lost.
function processPackage {
        param($pkgname, $pkgSvcBinary, $pkgSvcExists)

        blank
        verboseLog "Processing package $pkgName"
        blank

        verboseLog "Installing binaries for $pkgName"
        workerFunc $pkgname
        verboseLog "$pkgname package installed"
        blank

        blank
        $svcname = $pkgname.ToLower()
        verboseLog "Installing $svcname service"
        $pkgDirPath = Join-Path "$intDestPath" -ChildPath "$pkgname"
        $pkgBinPath = Join-Path "$pkgDirPath" -ChildPath "$pkgSvcBinary"

        if ($pkgSvcExists) {
                verboseLog "Unregistering the existing $svcname service"
                if (-not $DryRun) {
                        & "$pkgBinPath" --unregister-service
                }
        }

        verboseLog "Invoking $pkgBinPath to register $svcname service"
        if (-not $DryRun) {
                & "$pkgBinPath" --register-service
                if ($LASTEXITCODE -ne 0) {
                        errorLog "Failed to register $svcname service - exit code $LASTEXITCODE"
                        exit
                }
        }

        if (-not $DryRun) {
                Set-Service docker -StartupType Automatic
        }

        verboseLog "Service $svcname registered and set to automatic"

        # Make sure the binary location is in the path
        $oldpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path

        $pathExists = checkPathExists "$oldpath" "$pkgDirPath"
        if (-not $pathExists) {

                verboseLog "Adding $pkgDirPath to system PATH"

                if (-not $DryRun) {
                        $newpath = "$oldpath`;$pkgDirPath"
                        Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newpath
                }
        } else {
                verboseLog "Skipping PATH modification: $pkgDirPath already exists in system PATH"
        }

        # Modify the current PATH also - so that calls to ctr and docker.exe work
        # OK to do so for dryrun as well since this only impacts the current process.
        $pathExists = checkPathExists "$Env:Path" "$pkgDirPath"
        if (-not $pathExists) {
                $Env:Path += "`;$pkgDirPath"
        }

        blank
}

# In case a service already existed, unregister and register it
# so that we always have a consistent state at the end.
# Verified (code and testing) that --unregister-service does not
# cause any existing windows events to be lost.
function uninstallPackage {
        param($pkgname, $pkgSvcBinary, $pkgSvcExists)

        blank
        verboseLog "Uninstalling package $pkgName"
        blank

        blank
        $svcname = $pkgname.ToLower()
        verboseLog "Uninstalling $svcname service"

        $pkgDirPath = Join-Path "$intDestPath" -ChildPath "$pkgname"
        $pkgBinPath = Join-Path "$pkgDirPath" -ChildPath "$pkgSvcBinary"

        if ($pkgSvcExists) {
                verboseLog "Unregistering the existing $svcname service"
                if (-not $DryRun) {
                        & "$pkgBinPath" --unregister-service
                }
        }

        # Remove package binaries
        Remove-Item -Recurse -Force "$pkgDirPath"

        # Make sure the binary location is removed from the path
        ensurePathNotExist "$pkgDirPath"
}

function reconcileParams {

        verboseLog "Reconciling parameters for the script"

        # Binaries CDN location - a default value must be specified
        $script:intDownloadUrl        =   Default `
                                          "$DownloadUrl" `
                                          "$env:DOWNLOAD_URL" `
                                          $DEFAULT_DOWNLOAD_URL
        verboseLog "Using Docker Url: $script:intDownloadUrl"

        # Channel name (e.g. test, stable etc.)
        $script:intChannel            =   Default `
                                          "$Channel" `
                                          "$env:CHANNEL" `
                                          $DEFAULT_CHANNEL
        VerboseWithCheck "Using Channel" "$script:intChannel"

        # Docker binaries version
        $script:intDockerVersion      =   Default `
                                         "$DockerVersion" `
                                         "$env:DOCKER_VERSION" `
                                         $DEFAULT_DOCKER_VERSION
        VerboseWithCheck "Using Docker Version" "$script:intDockerVersion"

        # Containerd binaries version
        $script:intContainerdVersion  =   Default `
                                          "$ContainerdVersion" `
                                          "$env:CONTAINERD_VERSION" `
                                          $DEFAULT_CONTAINERD_VERSION
        VerboseWithCheck "Using Containerd Version" "$script:intContainerdVersion"

        # Destination path for installing the binaries
        $script:intDestPath           =   Default `
                                          "$DestPath" `
                                          "" `
                                          $DEFAULT_DEST_PATH
        verboseLog "Using Destination Path: $script:intDestPath"

        $defLocation = Get-Location
        # Path for saving/loading for airgap installs
        $script:intOfflinePackagesPath =   Default `
                                          "$OfflinePackagesPath" `
                                          "" `
                                          $defLocation
        verboseLog "Using Offline Packages Path: $script:intOfflinePackagesPath"
}

# Because we only ever use the versions for informational messages,
# we treat errors here as non-fatal.
function getDockerVer {
        if (Get-Command "docker.exe" -ErrorAction SilentlyContinue)
        {
                $tmp = docker -v|Out-String
                if ($LASTEXITCODE -eq 0) {
                        $tmp = $tmp.Trim().split('	 ',3)
                        return $tmp[2]
                } else {
                        verboseLog "docker -v returned $LASTEXITCODE"
                }
        } else {
                verboseLog "docker not in PATH"
        }

        return ''
}

function getContainerdVer {
        if (Get-Command "ctr.exe" -ErrorAction SilentlyContinue)
        {
                $tmp = ctr -v|Out-String 
                if ($LASTEXITCODE -eq 0) {
                $tmp = $tmp.Trim().split('	 ',3)
                        return $tmp[2].Substring(1)
                } else {
                        verboseLog "ctr version returned $LASTEXITCODE"
                }
        } else {
                verboseLog "ctr not in PATH"
        }

        return ''
}

function initState {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        reconcileParams

        getServicesInstallStatus

        if ($script:dockerExists) {
                $script:initDockerVer = getDockerVer
        }

        if ($EngineOnly) {
                return
        }

        if ($script:containerdExists) {
                $script:initContainerdVer = getContainerdVer
        }
}

function processAllPackagesForInstall {

        processPackage "Docker"     "dockerd.exe"    $script:dockerExists
        $script:dockerExists = $TRUE

        if ($EngineOnly) {
                return
        }

        processPackage "Containerd" "containerd.exe" $script:containerdExists
        $script:containerdExists = $TRUE
}

function processAllPackagesForUninstall {

        if ($script:dockerExists) {
                uninstallPackage "Docker"     "dockerd.exe"  $script:dockerExists
                if (![string]::IsNullOrWhiteSpace($script:initDockerVer)) {
                        "Uninstalled package Docker $script:initDockerVer"
                } else {
                        "Uninstalled package Docker"
                }
                $script:dockerExists = $FALSE
        } else {
                "Uninstall - package Docker does not exist"
        }

        if ($EngineOnly) {
                return
        }

        if ($script:containerdExists) {
                uninstallPackage "Containerd" "containerd.exe" $script:containerdExists
                if (![string]::IsNullOrWhiteSpace($script:initContainerdVer)) {
                        "Uninstalled package Containerd $script:initContainerdVer"
                } else {
                        "Uninstalled package Containerd"
                }
                $script:containerdExists = $FALSE
        } else {
                "Uninstall - package Containerd does not exist"
        }
}

function printScriptVer {
        "install.ps1 version $SCRIPT_SEMVER_VERSION build $SCRIPT_COMMIT_SHA"
        if (![string]::IsNullOrWhiteSpace($PUBLISH_STRING)) {
                "For $PUBLISH_STRING"
        }
}

function installOrUninstall {
        if ($Ver) {
                printScriptVer
                exit
        }

        $rebootReminder = $FALSE

        if (-not $DryRun -and -not $DownloadOnly) {

            if (-not ([bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544"))) {
                    # Possible TODO: Addressing the need to have a non-admin access docker client
                    # This requires:
                    # 1.  Specifying a security group whose users can access docker client even if they are not admins
                    # 2.  Creation of this security group and adding a user to it
                    # Both of the above need admits so we cannot do that automatically at this stage.
                    # We could possibly provide guidance to what an adinistrator user of this script needs to do.
                    errorLog "Installation of Docker EE requires administrator rights on Windows"
                    "By adding the group option to the Docker Daemon config file, it is possible to execute Docker commands as non-admin."
                    "Specifying the Security group for allowing non-admins access to Docker:https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-docker/configure-docker-daemon#set-docker-security-group"
                    "To create SG and add user to it, execute as an admin: net localgroup <Group Name> /add && net localgroup <Group Name> <User Name> /add"
                    exit
            }
        }

        if (-not $DownloadOnly) {
            # The script should work as long as its prerequisites 
            # [Containers feature] is installed.
    
            # Make sure containers feature is enabled on the host
            if (-not $Uninstall) {
                    if ((get-windowsoptionalfeature -Online -FeatureName containers).State -ne 'Enabled') {
                            blank
                            blank
                            if (-not $DryRun) {
                                    "$CONTAINERS_FEATURE_NOT_INSTALLED"
                                    Invoke-Expression "Enable-WindowsOptionalFeature -Online -FeatureName containers -NoRestart -WarningAction SilentlyContinue -All"|Out-Null
                                    $rebootReminder = $TRUE
                            } else {
                                    "Containers feature is not installed and is required for Docker EE"
                                    "Dry run is ON - proceeding as if the feature was installed without actually installing it"
                            }
                            blank
                            blank
                    } else {
                        verboseLog "Verified that the feature Containers is installed"
                    }
            }
        }

        blank
        initState

        # Stopping services can impact network connectivity.
        # This is pronounced when dockerd is stopped and we
        # have reports of downloads failing as a result. So
        # we download before stopping the service(s).
        if (-not $Uninstall) {
                downloadAllPackagesForInstall

                if ($DownloadOnly) {
                        exit
                }

                if (-not $DryRun -and -not $EngineOnly) {
                        md -Force c:\k\cni\config | Out-Null
                }
        }

        # Stop existing services so that we could overwrite the binaries
        ensureExistingServicesStopped

        if ($Uninstall) {
                # Uninstall services
                processAllPackagesForUninstall
        } else {
                # Install services
                processAllPackagesForInstall

                # For DryRun, the version numbers have already been updated
                if (-not $DryRun) {
                        $script:finalDockerVer = getDockerVer
                        $script:finalContainerdVer = getContainerdVer
                }
        
                if (-not $EngineOnly) {
                        openPorts
                }
        
                # Unless we are asked to leave the services in a stopped state, we need to start them.
                if (-not $rebootReminder -and -not $NoServiceStarts) {
                        ensureExistingServicesStarted
                }
        
                blank
                # Before exiting, emit a message about different packages installed/upgraded
                # and their versions number(s) [pre-install and post-install].
                if ($script:finalDockerVer -ne '') {
                        if ($script:initDockerVer -ne '' -and $script:initDockerVer -ne $script:finalDockerVer) {
                                "Updated Docker from $script:initDockerVer to $script:finalDockerVer"
                        } else {
                                "Installed Docker $script:finalDockerVer"
                        }
                }
        
                if (-not $EngineOnly) {
                        if ($script:finalContainerdVer -ne '') {
                                if ($script:initContainerdVer -ne '' -and $script:initContainerdVer -ne $script:finalContainerdVer) {
                                        "Updated Containerd from $script:initContainerdVer to $script:finalContainerdVer"
                                } else {
                                        "Installed Containerd $script:finalContainerdVer"
                                }
                        }
                }
        
                blank
                "Install/upgrade completed"
        
                # Reboot > Logoff. So show only reboot message even if logoff is also set.
                if ($rebootReminder) {
                        Write-Warning $EXIT_REBOOT_MESSAGE
                } elseif ($script:mustLogoff) {
                        Write-Warning $EXIT_LOGOFF_MESSAGE
                }
        }
}

installOrUninstall
