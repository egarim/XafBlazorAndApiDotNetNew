# Xaf Blazor App Template

This repo contains the source code of a XAF Blazor application template for the dotnet CLI, the idea behind this template is to make easier the development of XAF applications in non-Windows environments like Linux or macOS

###### What is included?
- A XAF Blazor Application
- XAF API project
- Bash script to run the app
- Bash script to publish and monitor the app as as service as shown here https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/linux-apache?view=aspnetcore-6.0#monitor-the-app
- hosting.json file to easily configure listening address
- VS Code snippets 
- xdom: Template for XAF domain objects
- xprop: Template for persistent properties
- xpcl: XPCollection with association attribute (for the one side)
- xpa: Persistent property with association attribute (for the many side)
- xvc: Template for a XAF view controller
- xvw: Template for a windows controller
- xas: Simple action
- xac: Single choice action
- xap: Parametrized action
- xapw: Popup window show action 

###### How to install

```<language>
dotnet new --install Xaf.Blazor
```

###### How to create a new XAF Blazor app

```<language>
dotnet new XafBlazor -o MyAppName
```

###### To use bash scripts
To use bash scripts, you should change the permission of the bash script files as shown below
```<language>
chmod +x run.sh
cd MyApp.Blazor.Server
chmod +x InstallAsServiceUbuntu.sh
```
repeat the process for each .sh file

###### To publish and monitor the app

Go to your Xaf Blazor app folder and run the following command in the console

```<language>
cd MyApp.Blazor.Server

./InstallAsServiceUbuntu.sh 192.168.122.154 UserInRemoteServer /path/to/the/app y

```


###### Parameters

1. IP of the target server
2. User in the remote server
3. Path to deploy the app
4. Update or create the database/schema

Example
this is how the command should look like

```<language>

./InstallAsServiceUbuntu.sh 192.168.122.154 joche /home/joche y

```



