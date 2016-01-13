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

$installerPath = Download-File("https://www.rabbitmq.com/releases/rabbitmq-server/v$version/$fileName")

echo "Installing RabbitMQ"

& $installerPath /S | Out-Null

echo "DONE!"

$rabbitMqPath = Get-RabbitMqPath
Set-Location "$rabbitMqPath\sbin"

& "cmd.exe" /c "rabbitmq-service.bat" stop
& "cmd.exe" /c "rabbitmq-service.bat" enable rabbitmq_management --offline
& "cmd.exe" /c "rabbitmq-plugins.bat" enable rabbitmq_management
& "cmd.exe" /c "rabbitmq-service.bat" install
& "cmd.exe" /c "rabbitmq-service.bat" start
& "cmd.exe" /c "rabbitmqctl.bat" start_app
& "cmd.exe" /c "rabbitmqctl.bat" status

& "cmd.exe" /c "rabbitmqctl.bat" add_user $user $password
& "cmd.exe" /c "rabbitmqctl.bat" set_user_tags $user administrator
& "cmd.exe" /c "rabbitmqctl.bat" set_permissions -p / $user ".*" ".*" ".*"

echo ""
echo "RabbitMQ Management Plugin enabled at http://localhost:15672"
echo ""

echo "RabbitMQ user: $user password: $password"
