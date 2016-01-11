Import-Module SQLPS

$configFile = "C:\vagrant\DB\config.json"
$config = (Get-Content $configFile -Raw) | ConvertFrom-Json

ForEach ($db in $config.databases) {
	$name = $db.name
	$mdf = $db.mdf
	$ldf = $db.ldf

	$attachSql = "
		USE [master]
		GO
		CREATE DATABASE [$name] ON (FILENAME = '$mdf.mdf'),(FILENAME = '$ldf.ldf') for ATTACH
		GO
	"
	Invoke-Sqlcmd $attachSql -QueryTimeout 3600 -ServerInstance '.\SQLExpress'
}
