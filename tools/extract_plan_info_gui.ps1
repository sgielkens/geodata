Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- CREATE FORM ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "PDF Planfile Extractor"
$form.Size = New-Object System.Drawing.Size(600,500)
$form.StartPosition = "CenterScreen"

# --- CREATION DATE LABEL + BUTTON ---
$cmodLabel = New-Object System.Windows.Forms.Label
$cmodLabel.Text = "Aanmaakdatum:"
$cmodLabel.Location = New-Object System.Drawing.Point(20,20)
$cmodLabel.Size = New-Object System.Drawing.Size(100,20)
$form.Controls.Add($cmodLabel)

$datePicker = New-Object System.Windows.Forms.DateTimePicker
$datePicker.Location = New-Object System.Drawing.Point(120,20)
$datePicker.Format = "Short"
$form.Controls.Add($datePicker)

# --- PDF FOLDER LABEL + BUTTON ---
$pdfLabel = New-Object System.Windows.Forms.Label
$pdfLabel.Text = "PDF map:"
$pdfLabel.Location = New-Object System.Drawing.Point(20,60)
$pdfLabel.Size = New-Object System.Drawing.Size(100,20)
$form.Controls.Add($pdfLabel)

$pdfTextBox = New-Object System.Windows.Forms.TextBox
$pdfTextBox.Text = "C:\806 Kempkes\Splitsingen"
$pdfTextBox.Location = New-Object System.Drawing.Point(120,60)
$pdfTextBox.Size = New-Object System.Drawing.Size(350,20)
$form.Controls.Add($pdfTextBox)

$pdfButton = New-Object System.Windows.Forms.Button
$pdfButton.Text = "Browse"
$pdfButton.Location = New-Object System.Drawing.Point(480,58)
$form.Controls.Add($pdfButton)

# --- OUTPUT FOLDER LABEL + BUTTON ---
$outputLabel = New-Object System.Windows.Forms.Label
$outputLabel.Text = "Uitvoer map:"
$outputLabel.Location = New-Object System.Drawing.Point(20,100)
$outputLabel.Size = New-Object System.Drawing.Size(100,20)
$form.Controls.Add($outputLabel)

$outputTextBox = New-Object System.Windows.Forms.TextBox
$outputTextBox.Text = "C:\806 Kempkes\Splitsingen"
$outputTextBox.Location = New-Object System.Drawing.Point(120,100)
$outputTextBox.Size = New-Object System.Drawing.Size(350,20)
$form.Controls.Add($outputTextBox)

$outputButton = New-Object System.Windows.Forms.Button
$outputButton.Text = "Browse"
$outputButton.Location = New-Object System.Drawing.Point(480,98)
$form.Controls.Add($outputButton)

# --- STATUS BOX ---
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "Status verwerking"
$statusLabel.Location = New-Object System.Drawing.Point(250,140)
$statusLabel.Size = New-Object System.Drawing.Size(100,20)
$form.Controls.Add($statusLabel)

$statusBox = New-Object System.Windows.Forms.TextBox
$statusBox.Multiline = $true
$statusBox.ScrollBars = "Vertical"
$statusBox.Location = New-Object System.Drawing.Point(20,160)
$statusBox.Size = New-Object System.Drawing.Size(540,100)
$statusBox.ReadOnly = $true
$form.Controls.Add($statusBox)

# --- LOG BOX ---
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "Foutmeldingen"
$statusLabel.Location = New-Object System.Drawing.Point(255,280)
$statusLabel.Size = New-Object System.Drawing.Size(100,20)
$form.Controls.Add($statusLabel)

$logBox = New-Object System.Windows.Forms.TextBox
$logBox.Location = New-Object System.Drawing.Point(20,300)
$logBox.Size = New-Object System.Drawing.Size(540,100)
$logBox.Multiline = $true
$logBox.ScrollBars = "Vertical"
$logBox.ReadOnly = $true
$form.Controls.Add($logBox)

# --- PROCESS BUTTON ---
$processButton = New-Object System.Windows.Forms.Button
$processButton.Text = "Verwerk PDFs"
$processButton.Location = New-Object System.Drawing.Point(230,420)
$processButton.Size = New-Object System.Drawing.Size(120,30)
$form.Controls.Add($processButton)

# --- FOLDER BROWSER FUNCTION ---
$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog

# --- CONFIGURE PDFTOTEXT PATH ---
$pdfToTextPath = ".\tools\pdftotext.exe"


$pdfButton.Add_Click({

	if (! (Test-Path $pdfTextBox.Text) ) {
		$pdfTextBox.Text = "C:\"
	}

	$folderBrowser.SelectedPath = $pdfTextBox.Text

    if ($folderBrowser.ShowDialog() -eq "OK") {
        $pdfTextBox.Text = $folderBrowser.SelectedPath
    }
})

$outputButton.Add_Click({

	if (! (Test-Path $outputTextBox.Text) ) {
		$outputTextBox.Text = "C:\"
	}

	$folderBrowser.SelectedPath = $outputTextBox.Text

    if ($folderBrowser.ShowDialog() -eq "OK") {
        $outputTextBox.Text = $folderBrowser.SelectedPath
    }
})

# --- PROCESS LOGIC ---
$processButton.Add_Click({

	if (! (Test-Path $pdfToTextPath) ) {
		$logBox.AppendText("Tool $($PSScriptRoot + "\" + $pdfToTextPath) niet aanwezig`r`n")
		$logBox.AppendText("`r`n")
		return
	}

	$cmodDate = $datePicker.Value.Date

    $rootDirectory = $pdfTextBox.Text
    $outputFolder = $outputTextBox.Text

    if (!(Test-Path $rootDirectory) -or !(Test-Path $outputFolder)) {
        [System.Windows.Forms.MessageBox]::Show("Selecteer een bestaande map.")
        return
    }

    $results = @()
	$planFolders = @()
	$pdfFiles = @()

	$maandFolders = Get-ChildItem -Path $rootDirectory -Directory

# -- Select second level subdirs
	foreach ($maandFolder in $maandFolders) {
		$planFolders += Get-ChildItem $maandFolder.FullName -directory
	}

	$filteredplanFolders = $planFolders | Where-Object {
		$_.CreationTime -ge $cmodDate}
#		$_.LastWriteTime -ge $cmodDate}

	foreach ($planFolder in $filteredplanFolders) {
		$pdfFiles += Get-ChildItem -Path $planFolder.FullName -Recurse -Filter "*plan.pdf"
	}

	if ($pdfFiles.Count -eq 0) {
		$statusBox.AppendText("Geen PDF plandocumenten gevonden`r`n")
		$form.Refresh()
		return
	}

	$tempTxt = [System.IO.Path]::GetTempFileName()

    foreach ($pdfFile in $pdfFiles) {

		$order_number = $pdfFile.Basename -replace ' plan$',''
		$order_file = Join-Path $pdfFile.DirectoryName "$order_number.txt"

		$statusBox.AppendText("Verwerking van $($pdfFile.Name)`r`n")
        $form.Refresh()

        & $pdfToTextPath -table -f 2 -l 2 $pdfFile.FullName $tempTxt

        # Regex extraction for plan PDF
		$xValue = $null
	    $yValue = $null
	    $OrderNr = $null
	    $KadGem = $null

		$content = Get-Content $tempTxt -Raw
		
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

		# And for order text file
		$aantal = $null

		if (! (Test-Path $order_file) ) {
			$logBox.AppendText("Bij plandocument $($pdfFile.FullName):`r`n")
			$logBox.AppendText("Geen orderbestand $order_file`r`n")
			$logBox.AppendText("`r`n")
		} else {
			$lines = Get-Content $order_file

			for ($i = 0; $i -lt $lines.Count; $i++) {
				if ($lines[$i] -match 'Aantal$') {

					$nextLine = $lines[$i + 1]

					if ($nextLine -match '(\d+)\s*$') {
						$aantal = $Matches[1]
					}
				}
			}
		}

	    $results += [PSCustomObject]@{
			Ordernummer       = $OrderNr
			"X-Coordinaat"    = $xValue
			"Y-Coordinaat"    = $yValue
			"Kad. Gem."       = $KadGem
			Aantal		      = $aantal
		}
	}

	$csvPath = Join-Path $outputFolder "results.csv"
    $excelPath = Join-Path $outputFolder "results.xlsx"

	$tempCsvIn = [System.IO.Path]::GetTempFileName()
	$tempCsvOut = [System.IO.Path]::GetTempFileName()

    $results | Export-Csv -Path $tempCsvIn -NoTypeInformation -Delimiter ','

	# Remove double quotes and replace decimal comma by decimal point
	$regex_decimal = "^\d+\,\d+$"

	Import-Csv $tempCsvIn -Delimiter ',' | ForEach-Object {
		foreach ($prop in $_.PSObject.Properties) {
			if ($prop.Value -match "$regex_decimal") {
				$prop.Value = $prop.Value -replace ',', '.'
			}
		}
		$_
	} | Export-Csv $tempCsvOut -Delimiter ',' -NoTypeInformation

	(Get-Content $tempCsvOut) -replace '"' | Set-Content "$csvPath"

	Remove-Item $tempTxt -Force
	Remove-Item $tempCsvIn -Force
	Remove-Item $tempCsvOut -Force

    [System.Windows.Forms.MessageBox]::Show("Verwerking afgerond!")
})

# --- RUN FORM ---
$form.ShowDialog()