<powershell>

#Start-Sleep -Seconds 60

# [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Tls11, [Net.SecurityProtocolType]::Tls12, [Net.SecurityProtocolType]::Ssl3
# [Net.ServicePointManager]::SecurityProtocol = "Tls, Tls11, Tls12, Ssl3"

# #Download Git installer
# Set-ExecutionPolicy RemoteSigned -Force
# $installerPath = "C:\Git-2.32.0-64-bit.exe"
# $installerArgs = "/SILENT"

# Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/download/v2.47.0.windows.2/Git-2.47.0.2-64-bit.exe" -OutFile $installerPath
# Start-Process -Wait -FilePath $installerPath -ArgumentList $installerArgs -Verb RunAs

# # Add Git to PATH environment variable
# $GitPath = "C:\Program Files\Git\bin"
# $EnvPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
# [Environment]::SetEnvironmentVariable("PATH", "$EnvPath;$GitPath", "Machine")

# Install IIS
$siteName = "app_dotnet"
$docroot = "C:\inetpub\$siteName"
Install-WindowsFeature -Name Web-Server -IncludeManagementTools

#remove website padrao
Remove-WebSite -Name "Default Web Site"

#create appPool
New-WebAppPool -Name $siteName -ManagedRuntimeVersion ""

# Create a new website
New-Item -ItemType Directory -Force -Path $docroot
Set-WebConfigurationProperty -Filter /system.webServer/directoryBrowse -Name enabled -Value True -PSPath IIS:\ -Verbose
New-Website -Name $siteName -PhysicalPath $docroot -Port 8080 -ApplicationPool $siteName -Force -Verbose

Start-Website -Name $siteName


</powersheel>