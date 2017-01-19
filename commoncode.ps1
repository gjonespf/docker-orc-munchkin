$scriptpath = $MyInvocation.MyCommand.Path
$scriptdir = Split-Path $scriptpath

. $scriptdir/requirements.ps1

function Update-DockerVolumes()
{
    #TODO: Migrate all from shell scripts
    $VOLOPTIONS=""
    $VOLDRIVER="local"
    $STORAGE_SHARENAME="devops-storage"
    $STORAGE_VOLUMENAME="devops-storage"

    #TODO: Migrate azure from sh
    $dockerVolumesTxt=$(docker volume ls)
    $dockerVolumes = Convert-TextColumnsToObject $dockerVolumesTxt

    if( !($dockerVolumes | ?{ $_."VOLUME NAME" -eq "$STORAGE_VOLUMENAME"}) )  {
        docker volume create --name $STORAGE_VOLUMENAME -d $VOLDRIVER $VOLOPTIONS
    }
}
