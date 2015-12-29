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

#$process = Start-Process $downloadPath -ArgumentList "/S" -PassThru
#$process.WaitForExit()

echo "DONE!"


$rabbitMqPath = Get-RabbitMqPath
Start-Process "$rabbitMqPath\sbin\rabbitmq-service.bat" -ArgumentList "stop" -Wait
Start-Process "$rabbitMqPath\sbin\rabbitmq-plugins.bat" -ArgumentList "enable rabbitmq_management --offline" -Wait
Start-Process "$rabbitMqPath\sbin\rabbitmq-service.bat" -ArgumentList "start" -Wait
Start-Sleep -s 15
echo ""
echo "RabbitMQ Management Plugin enabled at http://localhost:15672"
echo ""

Start-Process "$rabbitMqPath\sbin\rabbitmqctl.bat" -ArgumentList "add_user $user $password" -Wait
Start-Process "$rabbitMqPath\sbin\rabbitmqctl.bat" -ArgumentList "set_user_tags $user administrator" -Wait
Start-Process "$rabbitMqPath\sbin\rabbitmqctl.bat" -ArgumentList "set_permissions -p / $user "".*"" "".*"" "".*"" " -Wait
echo "RabbitMQ user: $user password: $password"
