Import-Module SQLPS

$configFile = "C:\vagrant\DB\config.json"
$config = (Get-Content $configFile -Raw) | ConvertFrom-Json

If ($config.logins -ne $null) {
	ForEach ($login in $config.logins) {
		$name = $login.name
		$password = $login.password

		$loginSql = "
			USE [master]
			CREATE LOGIN [$name] WITH PASSWORD=N'$password', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
		"
		Invoke-Sqlcmd $loginSql -QueryTimeout 3600 -ServerInstance '.\SQLExpress'
	}
}

ForEach ($db in $config.databases) {
	$name = $db.name
	$mdf = $db.mdf
	$ldf = $db.ldf
	$users = $db.users

	$attachSql = "
		USE [master]
		CREATE DATABASE [$name] ON (FILENAME = '$mdf.mdf'),(FILENAME = '$ldf.ldf') for ATTACH
	"
	Invoke-Sqlcmd $attachSql -QueryTimeout 3600 -ServerInstance '.\SQLExpress'

	If ($users -ne $null) {
		ForEach($user in $users) {
			$userName = $user.userName
			$loginName = $user.loginName

			$userSql = "
				USE [$name]
				IF EXISTS (SELECT * FROM sys.database_principals WHERE name = N'$userName')
					EXEC sp_change_users_login 'Auto_Fix', '$userName'
				ELSE
					CREATE USER [$userName] FOR LOGIN [$loginName]
				EXEC sp_addrolemember N'db_owner', N'$userName'
			"
			Invoke-Sqlcmd $userSql -QueryTimeout 3600 -ServerInstance '.\SQLExpress'
		}
	}
}
