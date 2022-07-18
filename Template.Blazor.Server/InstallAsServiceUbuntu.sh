#!/bin/bash
# how to call the script  ./InstallApp.sh 192.168.122.166 joche /home/joche/ SimpleBlazor
#TODO how to read passwords https://stackoverflow.com/questions/12202587/automatically-enter-ssh-password-with-script
# print variable on a screen
#sudo ./remote.sh 192.168.122.154 joche /home/joche/ RemoteSudo.Blazor.Server 
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
}
function CreateServiceFile()
{
  #contact variables https://stackoverflow.com/questions/4181703/how-to-concatenate-string-variables-in-bash
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
  #contact variables https://stackoverflow.com/questions/4181703/how-to-concatenate-string-variables-in-bash
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
  #contact variables https://stackoverflow.com/questions/4181703/how-to-concatenate-string-variables-in-bash
  #installscriptfile="app_${AppName}/install.sh"
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
  echo "echo Do you want to update or create the database and schema [y/n]" >> $installscriptfile
  echo -e "read update\nif [[ \$update\ == \"y\" ]]\nthen\necho updating database\n./app_${AppName}/${AppName} --updateDatabase\nfi" >> $installscriptfile
  echo $copyservicecommand >> $installscriptfile
  echo $enablecommand >> $installscriptfile
  echo $startservicecommand >> $installscriptfile
  echo $servicestatuscommand >> $installscriptfile
  
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
  tar -czf release.tar.gz app_$AppName remove_${AppName}.sh install_${AppName}.sh status_${AppName}.sh
  rm remove_${AppName}.sh
  rm install_${AppName}.sh
  
}



echo Installation information
echo AppName:Template.Blazor.Server
echo Ip:$1
echo User:$2
echo Remote path:$3
echo The install process will start using the information above, press y to continue

AppName=Template.Blazor.Server
Ip=$1
User=$2
RemotePath=$3

read install

if [[ $install != "y" ]]
then
  echo Finishing script
  exit 0
fi

#ssh pass https://www.middlewareinventory.com/blog/shell-script-to-ssh-multiple-servers-with-password/
#apt install sshpass

echo "Enter the Remote Password"
read -s rmtpasswrd

DeletePublishingFiles
CompileApp
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
sshpass -p$rmtpasswrd ssh -t $User@$Ip "sudo $3/install_${AppName}.sh"

