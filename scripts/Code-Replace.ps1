using namespace System;

#file path
[String]$file = Read-Host -Prompt "Enter the file name";
$file = $file.Trim().Trim('"');

# exists
if ((Get-Item -Path $file).Exists) {

}