$scriptpath = $MyInvocation.MyCommand.Path
$scriptdir = Split-Path $scriptpath

$projdir= Resolve-Path "$scriptdir/../.."

Push-Location $PWD
cd $projdir
. $projdir/commoncode.ps1
Pop-Location

Update-DockerVolumes

docker-compose pull
docker-compose up -d
