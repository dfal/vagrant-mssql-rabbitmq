Function Download-File([string] $uri) {
	$downloadDir = "C:\vagrant\downloads"
	if (-Not (Test-Path $downloadDir)) { [void](New-Item -ItemType directory -Path $downloadDir) }

	$fileName = [System.IO.Path]::GetFileName($uri)
	$downloadPath = "$downloadDir\$fileName"

	if (-Not (Test-Path $downloadPath)) {
		[void](Write-Host "Downloading $uri")
		[void](new-object System.Net.WebClient).DownloadFile($uri, $downloadPath)
		[void](Write-Host "DONE!")
	}

	return $downloadPath
}
