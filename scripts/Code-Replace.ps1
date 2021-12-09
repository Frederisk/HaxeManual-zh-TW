using namespace System;
using namespace System.Text.RegularExpressions;

# file path
[String]$file = Read-Host -Prompt 'Enter the file path';
$file = $file.Trim().Trim('"');

# exists
if ((Get-Item -Path $file).Exists) {
    $dictionary =
    [String]$dictionary = Read-Host -Prompt 'Enter the source code dictionary path' | Join-Path -Path $dictionary -ChildPath '*';

    [String]$content = Get-Content -Path $file -Raw;

    Get-ChildItem -Path $dictionary -Include '*.hx'
    | ForEach-Object -Process {
        [String]$sourceCode = Get-Content -Path $_.FullName -Raw;
        $content = [Regex]::Replace($content, "(?i)^\[code asset\]\(assets\/$($_.NameString)\)", $sourceCode);
    }
    # write
    Set-Content -Path $file -Value $content;
}
else {
    Write-Error -Message 'File does not exist';
}