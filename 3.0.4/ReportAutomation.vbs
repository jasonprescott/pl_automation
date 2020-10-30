'Code should be placed in a .vbs file
ExcelFilePath = ".\AccountingInfoAutomation.xlsm"
MacroPath = "AnalyticalMacros.CreateStatisticalData"
Set objExcel = CreateObject("Excel.Application")
objExcel.Visible = False
objExcel.DisplayAlerts = False
MsgBox "Your report generation is about to start. Click OK to continue, you will be notified when the job is done, meanwhile, please, do not use Excel."
Set book = objExcel.Workbooks.Open(ExcelFilePath)
objExcel.Run MacroPath
objExcel.DisplayAlerts = True
book.Close
objExcel.Quit
MsgBox "Your report was generated in C:\damaga at " & TimeValue(Now), vbInformation
Set objExcel = Nothing
