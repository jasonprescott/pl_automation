$sourceFolder = Get-Location

start-process -FilePath "cmd.exe" -ArgumentList "/c cscript C:\dagama\ReportAutomation.vbs" -Wait -Passthru

$salesReportFileNameCriteria = "AccountancyReport_reserves*"

$finalReport = Get-ChildItem -Path "C:\dagama\" -Include $salesReportFileNameCriteria -Recurse | Select FullName, Name

$childPath = '\' + $finalReport[0].Name
$destination = Join-Path -Path $sourceFolder -ChildPath $childPath

Move-Item -Path $finalReport[0].FullName -Destination $destination