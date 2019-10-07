Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
iex "choco install putty vnc awscli"


aws s3 cp s3://muking-astrophotography/pixinsight/PI-windows-x64-1.8.7-20190930-c.exe pi.exe 
