Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms


#function selection csv file
function Select-File {
  param([string]$Directory = $PWD)

  $dialog = [System.Windows.Forms.OpenFileDialog]::new()
  $dialog.InitialDirectory = (Resolve-Path $Directory).Path
  $dialog.RestoreDirectory = $true

  $result = $dialog.ShowDialog()

  if($result -eq [System.Windows.Forms.DialogResult]::OK){
    return $dialog.FileName
  }
  else {
    exit;
  }
}

#function to select file location and set a name to the document
function Select-New-File {
  param([string]$Directory = $PWD)

  $dialog = [System.Windows.Forms.SaveFileDialog]::new()
  $dialog.InitialDirectory = (Resolve-Path $Directory).Path
  $dialog.RestoreDirectory = $true

  $result = $dialog.ShowDialog()

  if($result -eq [System.Windows.Forms.DialogResult]::OK){
    return $dialog.FileName
  }
  else {
    exit;
  }
}

$msgBoxInput =  [System.Windows.MessageBox]::Show('Wil je doorgaan met het exporteren van een CSV bestand naar een XLSX bestand?','Export CSV naar XLSX','YesNo')

  switch  ($msgBoxInput) {

  'Yes' {

    #define locations and delimiter
    [System.Windows.MessageBox]::Show("Kies het csv bestand dat je wilt omzetten")
    $csv = $path = Select-File #location from the file
    [System.Windows.MessageBox]::Show("Kies de locatie waar je het wilt opslaan en type de bestandsnaam in. Zorg dat je achter de naam .xlsx neerzet zodat het goed gaat.")
    $xlsx = Select-New-File #the location where it should be saved
    $delimiter = "," #specify the delimiter that is used in the file

    #make a new excel sheet with one empty sheet
    $excel = New-Object -ComObject excel.application 
    $workbook = $excel.Workbooks.Add(1)
    $worksheet = $workbook.worksheets.Item(1)

    #build the querytables.add command and format the data again
    $TxtConnector = ("TEXT;" + $path)
    $Connector = $worksheet.QueryTables.add($TxtConnector,$worksheet.Range("A1"))
    $query = $worksheet.QueryTables.item($Connector.name)
    $query.TextFileOtherDelimiter = $delimiter
    $query.TextFileParseType  = 1
    $query.TextFileColumnDataTypes = ,1 * $worksheet.Cells.Columns.Count
    $query.AdjustColumnWidth = 1

    $query.Refresh()
    $query.Delete()

    #save and close as xlsx
    $Workbook.SaveAs($xlsx,51)
    $excel.Quit()

  }

  'No' {

   exit;

  }

  }
