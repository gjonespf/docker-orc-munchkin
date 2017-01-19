$scriptpath = $MyInvocation.MyCommand.Path
$scriptdir = Split-Path $scriptpath
. $scriptdir/commoncode.ps1

#TODO: Registration?
$munchkin_projectname="orc-munchkin"
$munchkin_appname="docker-base-bootstrap"


function Update-BaseInfra()
{
	Push-Location
	cd munchkin-infra\compose\
	.\update.ps1
	Pop-Location
}

$cfg=Get-MunchkinConfiguration
Initialize-MunchkinConfiguration
Import-MunchkinProjectDependencies -Cfg $cfg

#TODO: Bootstrap env cfg
if(!(Test-DockerRunningInContainer))
{
	#Running in host, test some things out

	#Test docker components
	Test-DockerComponents

	#Base setups, submodules will handle any of their requirements
	Update-DockerInfraVolumes -Cfg $cfg
	Update-DockerInfraNetworks -Cfg $cfg

	#Make sure IIS isn't bound to port 80/443 at all (this is tested in the bootstrap script too)
	Test-DockerBoundPort -Port 80
	Test-DockerBoundPort -Port 443

	#Docker bootstrap
	$munchkinhomepath="$scriptdir/../munchkin-home/"
	$test=(New-Item -Path $munchkinhomepath -ItemType Directory -Force)
	$projdir=$(Resolve-Path $scriptdir/..)
	$munchkinhome=$(Resolve-Path $munchkinhomepath)
	Write-Host "Launching bootstrap in container to handle standing up infra (projdir: $projdir)"
	$test=(docker stop devops-toolbox-builder)
	$test=(docker rm devops-toolbox-builder)
	docker run --rm -it --name devops-toolbox-builder -v /var/run/docker.sock:/var/run/docker.sock:ro -v /etc:/media/host-etc -v ${munchkinhomepath}:/root/ -v ${projdir}:/media/projects -v ${scriptdir}:/media/bootstrap gavinjonespf/docker-toolbox:latest powershell "cd /media/bootstrap/; /media/bootstrap/bootstrap.ps1"

	#Launch BootstrapWebapp or Traefik in browser
	$launchUrl="https://traefik.$($Env:DOCKER_DC).$($Env:DOCKER_BASEDOMAIN):9001/"
	start $launchUrl

	Pause
	exit
}

#Default to just running base infra
Update-BaseInfra

#TODO: Restore backups if missing locally
Update-RestoreLocalStorage

#TODO: Bootstrap webapp
Update-BootstrapWebapp

#Test all stuffs
