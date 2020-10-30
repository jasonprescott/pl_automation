﻿function CheckMissingFiles() {

    Add-Type -AssemblyName PresentationFramework

    $checkIfExists = ""
    $result = ""
    $continueOrNot = "Not"
    $numberOfReservesFiles = 0
    $returnArray = @()

    $file = "DGM.F46.PL.101*"
    $checkIfExists = Get-ChildItem | Where-Object Name -Like $file
    

    if ($checkIfExists -eq $null) {
        $missingFiles = -join($missingFiles, "`n", $file)
    } else {
        $numberOfReservesFiles += 1
    }
    
    $file = "DGM.F47.PL.101*"
    $checkIfExists = Get-ChildItem | Where-object Name -Like $file

    if ($checkIfExists -eq $null) {
        $missingFiles = -join($missingFiles, "`n", $file)
    } else {
        $numberOfReservesFiles += 1
    }

    $file = "DGM.F48.PL.101*"
    $checkIfExists = Get-ChildItem | Where-object Name -Like $file

    if ($checkIfExists -eq $null) {
        $missingFiles = -join($missingFiles, "`n", $file)
    } else {
        $numberOfReservesFiles += 1
    }

    if ($missingFiles -ne $null) {
        $result = [System.Windows.MessageBox]::Show("These files are missing: " + $missingFiles,"Missing files. Do you want to continue?","OkCancel","Warning") 
        $returnArray += $result
        $returnArray += $numberOfReservesFiles
        
        Write-Host $numberOfReservesFiles
        Write-Host $returnArray

        return ,$returnArray   
    } else {        $returnArray += "Not"        $returnArray += $numberOfReservesFiles        return ,$returnArray
    } 
}

$continueOrNot = CheckMissingFiles

Write-Host $($continueOrNot[0])
Write-Host $($continueOrNot[1])


if( (($($continueOrNot[0]) -like "OK") -or ($($continueOrNot[0]) -like "Not")) -and ($($continueOrNot[1]) -gt 0) ) {

try {

Add-Type -AssemblyName PresentationFramework

function SearchString($pathToFile) {
    $check = Get-Content $pathToFile -First 1;
    $check -match "0,00            0,00"
}

function ChangePath($newFile, $ext) {
    $location = Get-Location
    $path = "$($location)\$($newFile)$($ext)"
    return $path
}

function copySalesCheckFile {
    Get-ChildItem -Path .\ -Filter '*.csv' | ForEach-Object {(Get-Content $_.FullName).Replace('.',',') | Out-File 'C:\dagama\SalesIncomeCheck.csv'}
}

Function OpenWithTxtEditor{
Param($file)
    Start-Process  -filepath ((Get-ItemProperty -Path 'Registry::HKEY_CLASSES_ROOT\txtfile\shell\open\command').'(Default)').trimend(" %1") -ArgumentList $file
}

function removeFirstLine($a, $b) {
    $skip = 1
    $inPath = $a
    $outPath = $b

    Write-Host ("The output path is like: " + $outPath)

    $ins = New-Object System.IO.StreamReader $inPath
    $outs = New-Object System.IO.StreamWriter $outPath

    try {
        # Skip the first N lines, but allow for fewer than N, as well
        for( $s = 1; $s -le $skip -and !$ins.EndOfStream; $s++ ) {
            $ins.ReadLine()
        }
        while( !$ins.EndOfStream ) {
            $outs.WriteLine( $ins.ReadLine() )
        }
    }
    finally {
        $outs.Close()
        $ins.Close()
    }
    }


#Retrieves a list of files which begin with DGM

$listOfReserveFiles = Get-ChildItem -Include "DGM.F46*", "DGM.F47*", "DGM.F48*" -Recurse | Select FullName, Name

#Retries the number of files in the list for the loop
$numberOfReserveFiles = $listOfReserveFiles.Count

	
$MessageboxTitle = “This file isn't null-check. Do you want to open it?”	
$MessageIcon = [System.Windows.MessageBoxImage]::Warning
$ButtonType = [System.Windows.MessageBoxButton]::YesNoCancel

For ($i = 0; $i -lt $numberOfReserveFiles; $i++) {
    
    #Retrieves the full path to the current file in the list on the $i position
    $currentPositionFilePath = $listOfReserveFiles[$i].FullName
    
    #Sets the path for the _cut file which will be the one without the first line
    $cutPath = $currentPositionFilePath + '_cut'
    
    #Tests whether the file really exists (a security measure for any incident)
    if (Test-Path $currentPositionFilePath) {
        if (SearchString($currentPositionFilePath)) { #Searches the first line for a specific string
            removeFirstLine $currentPositionFilePath $cutPath #Removed the first line from the file which has the proper string in it
        } else {
            
            $Messageboxbody = $listOfReserveFiles[$i].Name

            $result = [System.Windows.MessageBox]::Show($Messageboxbody,$MessageboxTitle,$ButtonType,$messageicon)
            
            Write-Host "Your choice is $result"
            if ($result -like "Yes") {
            OpenWithTxtEditor $currentPositionFilePath
            $i--
            }
        }
    }
}

#Checks whether the folder C:\dagama exists
$folderExists = Test-Path C:\dagama

#If the folder does not exist, create a new one
if (-not $folderExists) {
    New-Item -Path 'C:\dagama' -ItemType Directory |%{$_.Attributes = "hidden"}
}

$directoryPath = 'C:\dagama'

#Checks whether the output merged file exists, if yes, then remove it
$fileExists = Test-Path 'C:\dagama\data_reserves_merged.txt'
 if ($fileExists) {
    Remove-Item -Path C:\dagama\* -Include *.txt
 }

#Checks whether the SalesIncome XLSX file exists, if yes, then remove it
 $xlsxExists = Test-Path 'C:\dagama\SalesIncomeCheck.xlsx'
 if ($xlsxExists) {
    Remove-Item -Path C:\dagama\* -Include *.xlsx
 }

#Checks whether the SalesIncome XLS file exists, if yes, then remove it
 $xlsExists = Test-Path 'C:\dagama\SalesIncomeCheck.xls'
 if ($xlsExists) {
     Remove-Item -Path C:\dagama\* -Include *.xls
 }

 #Copies the SalesCheckFile
 copySalesCheckFile

 } finally {

$listOfCutFiles = Get-ChildItem | Where-Object Name -Like '*_cut*'


#Concatenates all files without their first lines into one
cat $listOfCutFiles | sc "C:\dagama\data_reserves_merged.txt"

#Removes the redundant temporary files for each record before the concatenation after removing their first lines
Get-ChildItem | Where-Object Name -Like '*_cut*' | ForEach-Object { Remove-Item -LiteralPath $_.Name }

[System.Windows.MessageBox]::Show("Your data source has been generated.","Job done!",0,"Information")
}

} else {

[System.Windows.MessageBox]::Show("There are no source files!","Script terminated.",0,"Warning")
break;}