#!/bin/bash

DeletePublishingFiles() 
{
      #deleting publish dir and tar file
    if [ -d "app_$AppName" ]
    then
    echo removing app_$AppName folder
    rm -rf app_$AppName
    fi

    if test -f release.tar.gz
    then
    echo deleting release.tar.gz
    rm release.tar.gz
    fi
    
    if test -f install_${AppName}.sh
    then
    echo deleting install_${AppName}.sh
    rm install_${AppName}.sh
    fi

}
function CreateServiceFile()
{

  servicefilepath="app_${AppName}/${AppName}.service"
  touch $servicefilepath
  echo '[Unit]' >> $servicefilepath
  description="Description=Dispatch service for ${AppName}.service server"
  echo $description  >> $servicefilepath
  echo '' >> $servicefilepath
  echo '[Service]' >> $servicefilepath
  workingdirectory="WorkingDirectory=${RemotePath}/app_${AppName}"
  echo $workingdirectory >> $servicefilepath
  execstart="ExecStart=${RemotePath}/app_${AppName}/${AppName}"
  echo $execstart >> $servicefilepath
  echo "Restart=always" >> $servicefilepath
  echo "#Restart service after 10 seconds if the dotnet service crashes" >> $servicefilepath
  echo "RestartSec=10" >> $servicefilepath
  echo "KillSignal=SIGINT" >> $servicefilepath
  syslogidentifier="SyslogIdentifier=${AppName}"
  echo $syslogidentifier >> $servicefilepath
  user="User=${User}"
  echo $user >> $servicefilepath
  echo "Environment=ASPNETCORE_ENVIRONMENT=Production" >> $servicefilepath
  echo '' >> $servicefilepath
  echo '[Install]' >> $servicefilepath
  echo 'WantedBy=multi-user.target' >> $servicefilepath
  
}
function CreateStatusFile()
{
  
  statusfilepath="status_${AppName}.sh"
  touch $statusfilepath
  servicestatuscommand="sudo systemctl status ${AppName}.service"
  echo $servicestatuscommand >> $statusfilepath
  
  
}
function CreateRemoveScript()
{
  removescript="remove_${AppName}.sh"
  touch $removescript
  stopservicecommand="sudo systemctl stop ${AppName}.service"
  disblecommand="sudo systemctl disable ${AppName}.service"
  removeservicecommand="sudo rm  /etc/systemd/system/${AppName}.service"
  killprocesscommand="ps -ef | grep ${AppName} | grep -v grep | awk '{print $2}' | xargs kill";
  removedircommnad="rm -rf app_${AppName}"
  echo $stopservicecommand >> $removescript
  echo $disblecommand >> $removescript
  echo $removeservicecommand >> $removescript
  echo $killprocesscommand >> $removescript
  #echo $removedircommnad >> $removescript
}
function CreateInstallScript()
{
  
  installscriptfile="install_${AppName}.sh"
  touch $installscriptfile
  aptupdate="sudo apt-get update -y";
  libgdiplus="sudo apt-get install -y libgdiplus";
  copyservicecommand="sudo yes | cp app_${AppName}/${AppName}.service /etc/systemd/system/"
  enablecommand="sudo systemctl enable ${AppName}.service"
  chmodcommand="chmod +x app_${AppName}/${AppName}"
  servicestatuscommand="sudo systemctl status ${AppName}.service"
  startservicecommand="sudo systemctl start ${AppName}.service"

  echo $aptupdate >> $installscriptfile
  echo $libgdiplus >> $installscriptfile
  echo $chmodcommand >> $installscriptfile
  echo $copyservicecommand >> $installscriptfile
  echo $enablecommand >> $installscriptfile
 # if [[ $UpdateCreateSchema == "y" ]]
 # then
 #   echo "echo Running database updater..." >> $installscriptfile
 #   echo "cd app_${AppName}" >> $installscriptfile
 #   echo "./${AppName} --updateDatabase" >> $installscriptfile
 #   echo "echo trying to change ownership of the database,this will fail if you are not using the default sqlite connection string" >> $installscriptfile
 #   echo "cd .." >> $installscriptfile
 #   echo "echo changing owner to $User" >> $installscriptfile
 #   echo "chown $User $DatabaseName" >> $installscriptfile
 #   echo "echo adding read write permissions to $User" >> $installscriptfile
 #   echo "chmod +rwx $DatabaseName" >> $installscriptfile
 #fi
 
 
  echo $startservicecommand >> $installscriptfile
  echo $servicestatuscommand >> $installscriptfile
  
}
function CreateDbUpdateScript()
{
  
  dbupdatescriptfile="dbupdate_${AppName}.sh"
  touch $dbupdatescriptfile
  echo "echo Running database updater..." >> $dbupdatescriptfile
  echo "cd app_${AppName}" >> $dbupdatescriptfile
  echo "./${AppName} --updateDatabase" >> $dbupdatescriptfile
  echo "echo trying to change ownership of the database,this will fail if you are not using the default sqlite connection string" >> $dbupdatescriptfile
  echo "cd .." >> $dbupdatescriptfile
  echo "echo changing owner to $User" >> $dbupdatescriptfile
  echo "chown $User $DatabaseName" >> $dbupdatescriptfile
  echo "echo adding read write permissions to $User" >> $dbupdatescriptfile
  echo "chmod +rwx $DatabaseName" >> $dbupdatescriptfile
 
  
  
}
function CreateStopScript()
{
  stopscript="stop_${AppName}.sh"
  touch $stopscript
  command="sudo systemctl stop ${AppName}.service"
  echo $command >> $stopscript
}
function CreateStartScript()
{
  startscript="start_${AppName}.sh"
  touch $startscript
  command="sudo systemctl start ${AppName}.service"
  echo $command >> $startscript
}
function CompileApp()
{
  dotnet publish -c Release -r ubuntu-x64 --self-contained=true /p:PublishSingleFile=false --output app_$AppName

}
function CreateTarFile()
{
  chmod +x remove_${AppName}.sh
  chmod +x install_${AppName}.sh
  chmod +x status_${AppName}.sh
  chmod +x start_${AppName}.sh
  chmod +x stop_${AppName}.sh
  chmod +x dbupdate_${AppName}.sh

  tar -czf release.tar.gz app_$AppName remove_${AppName}.sh install_${AppName}.sh status_${AppName}.sh start_${AppName}.sh stop_${AppName}.sh dbupdate_${AppName}.sh
  
  rm remove_${AppName}.sh
  rm install_${AppName}.sh
  rm status_${AppName}.sh
  rm start_${AppName}.sh
  rm stop_${AppName}.sh
  rm dbupdate_${AppName}.sh

  
}

UpdateCreateSchema="n"
if [[ $4 == "y" ]]
then
  UpdateCreateSchema="y"
fi

echo Installation information
echo AppName:Template.Blazor.Server
echo Ip:$1
echo User:$2
echo Remote path:$3
echo Create/update schema:$UpdateCreateSchema
echo The install process will start using the information above, press y to continue

AppName=Template.Blazor.Server
Ip=$1
User=$2
RemotePath=$3
DatabaseName=Template.db


read install

if [[ $install != "y" ]]
then
  echo Finishing script
  exit 0
fi

#todo move this to prerequisites
#ssh pass https://www.middlewareinventory.com/blog/shell-script-to-ssh-multiple-servers-with-password/
#apt install sshpass

echo "Enter the Remote Password"
read -s rmtpasswrd

DeletePublishingFiles
CompileApp
CreateDbUpdateScript
CreateStartScript
CreateStopScript
CreateRemoveScript
CreateServiceFile
CreateInstallScript
CreateStatusFile
CreateTarFile

chmod -x app_$AppName/$AppName

echo copying release files using $User
sshpass -p$rmtpasswrd scp release.tar.gz $2@$1:$3

echo 

sshpass -p$rmtpasswrd ssh $User@$Ip tar -xvzf $3/release.tar.gz 

echo the remote password will be ask one more time to install the app as a service
sshpass -p$rmtpasswrd ssh -t $User@$Ip "$3/dbupdate_${AppName}.sh"
sshpass -p$rmtpasswrd ssh -t $User@$Ip "sudo $3/install_${AppName}.sh"

