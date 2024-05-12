<#
This script renames all files in a directory with an incrementing number appended to the original filename.
#>

# Define the directory
$directory = "/Documents/filedirectory"
# Get all files in the directory
$files = Get-ChildItem -Path $directory -File
# Initialize counter
$counter = 1

# Loop through each file
foreach ($file in $files) {
    # Generate new filename with incrementing number
    $newFileName = "filenameofchoice" + "_" + $counter.ToString("D4") + $file.Extension
    # Rename the file
    Rename-Item -Path $file.FullName -NewName $newFileName
    # Increment counter
    $counter++
    # Reset counter if it exceeds 9999
    #if ($counter -gt 9999) {
    #    $counter = 1
    #}
}
