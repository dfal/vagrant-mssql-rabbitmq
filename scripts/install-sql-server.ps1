. "C:\vagrant\scripts\download-file.ps1"

$downloadPath = Download-File "http://download.microsoft.com/download/E/A/E/EAE6F7FC-767A-4038-A954-49B8B05D04EB/ExpressAndTools%2064BIT/SQLEXPRWT_x64_ENU.exe"

echo "Installing SQL Server 2008 Express R2, it will take a while..."

$process = Start-Process $downloadPath -ArgumentList "/Q" -Wait -PassThru
if ($process.ExitCode -ne 0) { throw  "Installation failed, error: " + [string]$process.ExitCode }

$process = Start-Process "C:\Windows\SysWOW64\SQLEXPRWT_x64_ENU\SETUP.exe" -ArgumentList "/Q /Action=install /INSTANCENAME=""SQLEXPRESS"" /INSTANCEID=""SQLExpress"" /IAcceptSQLServerLicenseTerms /FEATURES=SQL,Tools /TCPENABLED=1 /SECURITYMODE=""SQL"" /SAPWD=""#SAPassword!""" -Wait -PassThru
if ($process.ExitCode -ne 0) { throw  "Installation failed, error: " + [string]$process.ExitCode }

echo "DONE!"
