<#
This script calculates the hash of a file and compares it to the hash of all files in a directory.
#>

#### GET THE HASH OF A FILE YOU WANT TO COMPARE
# Specify the path to the file
$filePath = "/Documents/ISO/filename.iso"
# Calculate the hash
$fileHashBase = Get-FileHash -Path $filePath -Algorithm SHA256
# Print the hash
$hash = $fileHashBase.hash


#### GET THE HASH OF ALL FILES IN A DIRECTORY YOU WANT TO SEARCH
# Specify the path to the directory
$dirPath = "/Documents/ISO"
# Get all files in the directory
$files = Get-ChildItem -Path $dirPath -File
# Calculate and print the hash for each file
foreach ($file in $files) {
    $fileHash = Get-FileHash -Path $file.FullName -Algorithm SHA256
    if ($fileHash.hash -eq $hash) {
        Write-Output "Duplicate file found: $($file.Name), Hash: $($fileHash.Hash)"
    }
}
