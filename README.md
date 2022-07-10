Xaf.Blazor

This repo contains the source code of a XAF Blazor application template for the dotnet CLI, the idea behind this template is to make easier the development of XAF applications in non-Windows environments like Linux or macOS

What is included?
- A XAF Blazor Application
- XAF API project
- Bash script to run the app
- VS Code snippets 
- xprop: Template for persistent properties
- xdom: Template for XAF domain objects
- xvc: Template for a XAF view controller
- xvw: Template for a windows controller
- xas: Simple action
- xac: Single choice action
- xap: Parametrized action
- xapw: Popup window show action 

How to install
dotnet new --install Xaf.Blazor
How to create a new XAF Blazor app
dotnet new XafBlazor -o MyAppName
To use bash scripts
To use bash scripts, you should change the permission of the bash script files as shown below
chmod +x run.sh
repeat the process for each .sh file
