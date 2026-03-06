Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- CONFIGURE PDFTOTEXT PATH ---
$pdfToTextPath = ".\pdftotext.exe"

# --- CREATE FORM ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "PDF Coordinate Extractor"
$form.Size = New-Object System.Drawing.Size(600,300)
$form.StartPosition = "CenterScreen"

# --- PDF FOLDER LABEL + BUTTON ---
$pdfLabel = New-Object System.Windows.Forms.Label
$pdfLabel.Text = "PDF Folder:"
$pdfLabel.Location = New-Object System.Drawing.Point(20,20)
$pdfLabel.Size = New-Object System.Drawing.Size(100,20)
$form.Controls.Add($pdfLabel)

$pdfTextBox = New-Object System.Windows.Forms.TextBox
$pdfTextBox.Location = New-Object System.Drawing.Point(120,20)
$pdfTextBox.Size = New-Object System.Drawing.Size(350,20)
$form.Controls.Add($pdfTextBox)

$pdfButton = New-Object System.Windows.Forms.Button
$pdfButton.Text = "Browse"
$pdfButton.Location = New-Object System.Drawing.Point(480,18)
$form.Controls.Add($pdfButton)

# --- OUTPUT FOLDER LABEL + BUTTON ---
$outputLabel = New-Object System.Windows.Forms.Label
$outputLabel.Text = "Output Folder:"
$outputLabel.Location = New-Object System.Drawing.Point(20,60)
$outputLabel.Size = New-Object System.Drawing.Size(100,20)
$form.Controls.Add($outputLabel)

$outputTextBox = New-Object System.Windows.Forms.TextBox
$outputTextBox.Location = New-Object System.Drawing.Point(120,60)
$outputTextBox.Size = New-Object System.Drawing.Size(350,20)
$form.Controls.Add($outputTextBox)

$outputButton = New-Object System.Windows.Forms.Button
$outputButton.Text = "Browse"
$outputButton.Location = New-Object System.Drawing.Point(480,58)
$form.Controls.Add($outputButton)

# --- STATUS BOX ---
$statusBox = New-Object System.Windows.Forms.TextBox
$statusBox.Multiline = $true
$statusBox.ScrollBars = "Vertical"
$statusBox.Location = New-Object System.Drawing.Point(20,100)
$statusBox.Size = New-Object System.Drawing.Size(540,100)
$form.Controls.Add($statusBox)

# --- PROCESS BUTTON ---
$processButton = New-Object System.Windows.Forms.Button
$processButton.Text = "Process PDFs"
$processButton.Location = New-Object System.Drawing.Point(230,220)
$processButton.Size = New-Object System.Drawing.Size(120,30)
$form.Controls.Add($processButton)

# --- FOLDER BROWSER FUNCTION ---
$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog

$pdfButton.Add_Click({
    if ($folderBrowser.ShowDialog() -eq "OK") {
        $pdfTextBox.Text = $folderBrowser.SelectedPath
    }
})

$outputButton.Add_Click({
    if ($folderBrowser.ShowDialog() -eq "OK") {
        $outputTextBox.Text = $folderBrowser.SelectedPath
    }
})

# --- PROCESS LOGIC ---
$processButton.Add_Click({

    $rootDirectory = $pdfTextBox.Text
    $outputFolder = $outputTextBox.Text

    if (!(Test-Path $rootDirectory) -or !(Test-Path $outputFolder)) {
        [System.Windows.Forms.MessageBox]::Show("Please select valid folders.")
        return
    }

    $results = @()
    $pdfFiles = Get-ChildItem -Path $rootDirectory -Recurse -Filter "*plan.pdf"

    foreach ($pdfFile in $pdfFiles) {

        $statusBox.AppendText("Processing $($pdfFile.Name)...`r`n")
        $form.Refresh()

        $tempTxt = [System.IO.Path]::GetTempFileName()

        & $pdfToTextPath -table -f 2 -l 2 $pdfFile.FullName $tempTxt

        $content = Get-Content $tempTxt -Raw

        $xValue = $null
	    $yValue = $null
	    $OrderNr = $null
	    $KadGem = $null
		
        # Regex extraction	
	    $regex_coor = "\s+(\d+\,\d+)"
	    $regex_nr = "\s+(\d+)"
	    $regex_gem = "\s+(\w+\d+)"

        if ($content -match "X-Coordinaat$regex_coor") {
            $xValue = $matches[1]
        }

        if ($content -match "Y-Coordinaat$regex_coor") {
            $yValue = $matches[1]
        }
	
	    if ($content -match "Ordernummer$regex_nr") {
            $OrderNr = $matches[1]
        }
	
	    if ($content -match "Kad. Gem.$regex_gem") {
            $KadGem = $matches[1]
        }

        $results += [PSCustomObject]@{
#            FileName = $pdfFile.FullName
		    Ordernummer       = $OrderNr
            "X-Coordinaat"    = $xValue
            "Y-Coordinaat"    = $yValue
		    "Kad. Gem."       = $KadGem
        }

        Remove-Item $tempTxt -Force
    }

    $csvPath = Join-Path $outputFolder "results.csv"
    $excelPath = Join-Path $outputFolder "results.xlsx"

    $results | Export-Csv -Path $csvPath -NoTypeInformation
#    $results | Export-Excel -Path $excelPath -WorksheetName "Results" -AutoSize -BoldTopRow -FreezeTopRow

    [System.Windows.Forms.MessageBox]::Show("Processing complete!")
})

# --- RUN FORM ---
$form.ShowDialog()