. "C:\vagrant\scripts\download-file.ps1"

$erlVersion = "7.2.1"
$version = "18.2.1"
$fileName = "otp_win64_$version.exe"

$downloadPath = Download-File("http://www.erlang.org/download/$fileName")

echo "Installing Erlang"

$process = Start-Process $downloadPath -ArgumentList "/S" -Wait -PassThru
if ($process.ExitCode -ne 0) { throw  "Installation failed, error: " + [string]$process.ExitCode }

echo "DONE!"

[System.Environment]::SetEnvironmentVariable("ERLANG_HOME", "$env:ProgramFiles\erl$erlVersion", "Machine")
$env:ERLANG_HOME = "$env:ProgramFiles\erl$erlVersion"
