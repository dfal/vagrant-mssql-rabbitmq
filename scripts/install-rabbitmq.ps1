. "C:\vagrant\scripts\download-file.ps1"

$version = "3.6.0"
$fileName = "rabbitmq-server-$version.exe"
$user = "rabbit"
$password = "rabbit"

function Get-RabbitMqPath {
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\RabbitMQ"
    if (Test-Path "HKLM:\SOFTWARE\Wow6432Node\") { $regPath = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\RabbitMQ" }
    $path = Split-Path -Parent (Get-ItemProperty $regPath "UninstallString").UninstallString
    $version = (Get-ItemProperty $regPath "DisplayVersion").DisplayVersion
    return "$path\rabbitmq_server-$version"
}

$downloadPath = Download-File("https://www.rabbitmq.com/releases/rabbitmq-server/v$version/$fileName")

echo "Installing RabbitMQ"
$process = Start-Process $downloadPath "/S" -PassThru
$process.WaitForExit()
if ($process.ExitCode -ne 0) { throw "RabbitMQ installation failed, error: " + $process.ExitCode }
echo "DONE!"


$rabbitMqPath = Get-RabbitMqPath
Start-Process -Wait "$rabbitMqPath\sbin\rabbitmq-service.bat" "stop"
Start-Process -Wait "$rabbitMqPath\sbin\rabbitmq-service.bat" "enable rabbitmq_management --offline"
Start-Process -Wait "$rabbitMqPath\sbin\rabbitmq-plugins.bat" "enable rabbitmq_management"
Start-Process -Wait "$rabbitMqPath\sbin\rabbitmq-service.bat" "install"
Start-Process -Wait "$rabbitMqPath\sbin\rabbitmq-service.bat" "start"
Start-Process -Wait "$rabbitMqPath\sbin\rabbitmqctl.bat" "start_app"

echo ""
echo "RabbitMQ Management Plugin enabled at http://localhost:15672"
echo ""

Start-Process -Wait "$rabbitMqPath\sbin\rabbitmqctl.bat" "add_user $user $password"
Start-Process -Wait "$rabbitMqPath\sbin\rabbitmqctl.bat" "set_user_tags $user administrator"
Start-Process -Wait "$rabbitMqPath\sbin\rabbitmqctl.bat" "set_permissions -p / $user "".*"" "".*"" "".*"""
echo "RabbitMQ user: $user password: $password"
