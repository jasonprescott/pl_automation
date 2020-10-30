
Add-Type -AssemblyName PresentationFramework

$desiredDate = Read-Host -Prompt 'Date in a format YYYY-MM-dd'
$baseCurrency = 'EUR'
$targetCurrency = Read-Host -Prompt 'Target currency e.g. PLN'

function getRates($desiredDate, $baseCurrency, $targetCurrency) {

$postCode = "http://data.fixer.io/api/" + $desiredDate + "?access_key=110ec282bb6a5d6f8757399e64ba94b4&base=" + $baseCurrency + "&symbols=" + $targetCurrency

$apiCall = Invoke-WebRequest $postCode
$ratesObject = $apiCall | ConvertFrom-Json | Select 'rates'
$rate = $ratesObject.rates
$desiredRate = $rate.$targetCurrency
write-host $desiredRate

$newFileName = "exchangeRate_" + $desiredDate +  ".txt"
$testPath = ".\" + $newFileName

$fileExists = Test-Path $testPath
 if ($fileExists) {
    Remove-Item -Path $testPath
 }

New-Item -Path .\ -Name $newFileName -ItemType "file" -Value $desiredRate

}

If ($desiredDate -and $baseCurrency -and $targetCurrency) {

getRates $desiredDate $baseCurrency $targetCurrency

} Else {
    [System.Windows.MessageBox]::Show("You forgot some parameter.","Script will now terminate!",0,"Warning")
    break;
}

