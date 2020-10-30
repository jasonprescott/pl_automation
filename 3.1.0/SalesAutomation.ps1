$sourceFolder = Get-Location

$argumentPath = Join-Path -Path $sourceFolder -ChildPath "\ReportAutomation.vbs"
$argumentsList = "/c cscript " + $argumentPath

start-process -FilePath "cmd.exe" -ArgumentList $argumentsList -Wait -Passthru
#start-process -FilePath "cmd.exe" -ArgumentList "/c cscript .\ReportAutomation.vbs" -Wait -Passthru

$salesReportFileNameCriteria = "AccountancyReport_sales*"

$finalReport = Get-ChildItem -Path "C:\dagama\" -Include $salesReportFileNameCriteria -Recurse | Select FullName, Name

$childPath = '\' + $finalReport[0].Name
$destination = Join-Path -Path $sourceFolder -ChildPath $childPath

Move-Item -Path $finalReport[0].FullName -Destination $destination