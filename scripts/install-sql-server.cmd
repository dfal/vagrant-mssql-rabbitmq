@echo off
echo Installing SQL Server 2008 Express R2, it will take a while...
C:\vagrant\downloads\SQLEXPRWT_x64_ENU.exe /Q
C:\Windows\system32\SQLEXPRWT_x64_ENU\SETUP.EXE /Q /Action=install /INSTANCENAME="SQLEXPRESS" /INSTANCEID="SQLExpress" /IAcceptSQLServerLicenseTerms /FEATURES=SQL,Tools /TCPENABLED=1 /SECURITYMODE="SQL" /SAPWD="#SAPassword!"
echo DONE!

