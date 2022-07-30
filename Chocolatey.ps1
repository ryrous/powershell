# Install Chocolatey
Set-ExecutionPolicy Unrestricted -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Chocolatey Extensions and Updates
choco install chocolatey-compatibility.extension
choco install chocolatey-core.extension
choco upgrade chocolatey

# AWS
choco install amazon-workspaces
choco install awscli

# Azure
choco install az.powershell
choco install azure-cli

# Browsers
choco install chromium
choco install firefox
choco install googlechrome
choco install waterfox

# CPU-Z
choco install cpu-z
choco install hwmonitor

# DevOps
choco install busybox
choco install curl
choco install go
choco install hadoop
choco install jenkins-x
choco install octopustools
choco install octopusdeploy.tentacle
choco install python
choco install ruby
choco install sandboxie

# Docker
choco install docker-cli
choco install docker-desktop

# Git
choco install gh
choco install git

# HashiCorp
choco install packer
choco install terraform
choco install vault

# Intel
choco install intel-dsa
choco install intel-graphics-driver

# Java
choco install jre8

# Microsoft
choco install microsoft-edge
choco install microsoft-teams
choco install office365business
choco install onenote
choco install powerbi
choco install powertoys
choco install psexec
choco install sysinternals
choco install vcredist140
choco install vscode
choco install vscode-ansible
choco install vscode-go
choco install vscode-java
choco install vscode-powershell
choco install vscode-yaml

# nVidia
choco install geforce-experience
choco install nvidia-display-driver

# vmWare
choco install vmware-tools
choco install vmwareworkstation
choco install vmware-workstation-player

# Miscellaneous
choco install 1password
choco install 7zip
choco install atom
choco install authy-desktop
choco install ccleaner
choco install citrix-workspace
choco install datadog-agent
choco install filezilla
choco install itunes
choco install protonvpn
choco install putty
choco install slack
choco install teamviewer
choco install winscp