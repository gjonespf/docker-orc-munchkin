$scriptpath = $MyInvocation.MyCommand.Path
$scriptdir = Split-Path $scriptpath

. $scriptdir\bootstrap.ps1
