# Path to pdftotext.exe
$pdfToTextPath = "Q:\Kadaster\XPDF\xpdf-tools-win-4.06\bin64\pdftotext.exe"

# Root folder containing PDFs
$rootDirectory = "Q:\Kadaster"

# Output files
$outputCsv   = "Q:\Kadaster\results.csv"
$outputExcel = "Q:\Kadaster\results.xlsx"



# Ask user for root folder
$rootDirectory = Read-Host "Enter the full path to the folder containing the PDF files"

# Validate folder exists
if (-not (Test-Path $rootDirectory)) {
    Write-Host "The path does not exist. Script stopped." -ForegroundColor Red
    exit
}

# Ask where to save results
$outputFolder = Read-Host "Enter the folder where results should be saved"

if (-not (Test-Path $outputFolder)) {
    Write-Host "Output folder does not exist. Script stopped." -ForegroundColor Red
    exit
}

# Define output files
$outputCsv = Join-Path $outputFolder "results.csv"
$outputExcel = Join-Path $outputFolder "results.xlsx"




# Array to store results
$results = @()

# Get all PDF files recursively
$pdfFiles = Get-ChildItem -Path $rootDirectory -Recurse -Filter "*.pdf"

foreach ($pdfFile in $pdfFiles) {

    # Temporary file for extracted page 2
    $tempTxt = [System.IO.Path]::GetTempFileName()

    # Extract only page 2
    & $pdfToTextPath -table -f 2 -l 2 $pdfFile.FullName $tempTxt

    # Read content
    $content = Get-Content $tempTxt -Raw
	
	# Initialize values
    $xValue = $null
    $yValue = $null
	$OrderNr = $null
	$KadGem = $null
	
	$regex_coor = "\s+(\d+\,\d+)"
	$regex_nr = "\s+(\d+)"
	$regex_gem = "\s+(\w+\d+)"

    # Regex extraction
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

	    # Store result
    $results += [PSCustomObject]@{
        FileName = $pdfFile.FullName
        "X-Coordinaat"    = $xValue
        "Y-Coordinaat"    = $yValue
		Ordernummer       = $OrderNr
		"Kad. Gem."       = $KadGem
    }

    # Clean up
    Remove-Item $tempTxt -Force
}

# Export to CSV
$results | Export-Csv -Path $outputCsv -NoTypeInformation

# Export directly to Excel
#$results | Export-Excel -Path $outputExcel `
#                        -WorksheetName "Results" `
#                        -AutoSize `
#                        -BoldTopRow `
#                        -FreezeTopRow

Write-Host "Extraction complete."
Write-Host "CSV saved to: $outputCsv"
#Write-Host "Excel saved to: $outputExcel"
