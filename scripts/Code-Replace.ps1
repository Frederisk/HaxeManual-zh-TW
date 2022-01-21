using namespace System;
using namespace System.Text.RegularExpressions;

Import-Module -Name '.\scripts\Get-FilePathByIndex.psm1' | Out-Null;

# file path
[String]$fileIndex = Read-Host -Prompt 'Enter the file index';
[String]$file = Get-FilePathByIndex -FileIndex $fileIndex;
# exists
if (!((Get-Item -Path $file).Exists)) {
    Write-Error -Message 'File does not exist';
    exit 1;
}

[String]$content = Get-Content -Path $file -Raw;

[String]$dictionary = '..\HaxeManual\assets\*';
Get-ChildItem -Path $dictionary -Include '*.hx'
| ForEach-Object -Process {
    [String]$sourceCode = Get-Content -Path $_.FullName -Raw;
    $content = [Regex]::Replace(
        $content,
        "(?i)(?m)^\[code asset\]\(assets/$($_.NameString)\)",
        "<!-- [code asset](assets/$($_.NameString)) -->
``````haxe
$sourceCode
``````"
    );
} | Out-Null;
# write
Set-Content -Path $file -Value $content | Out-Null;

exit 0;
