using namespace System;
using namespace System.Collections.Generic;
using namespace System.Linq;

Import-Module -Name '.\scripts\Get-FilePathByIndex.psm1' | Out-Null;

# file path
[Int32]$fileIndex = Read-Host -Prompt "Enter the file index";
[String]$file = Get-FilePathByIndex -FileIndex $fileIndex;
# exists
if (!((Get-Item -Path $file).Exists)) {
    Write-Error -Message "File does not exist";
}

# file content
[String]$content = Get-Content -Path $file -Raw;
# term replace
[List[String[]]]$termList = [List[String[]]]::new();

Get-Content -Path .\Terminology.md
| Select-String -Pattern '^[\sa-z0-9_-]*?\|' -Raw
| ForEach-Object -Process {
    # for each term
    [String[]]$term = [Enumerable]::Select(
        $_.Split('|'),
        [Func[String, String]] { return $args[0].Trim(); }
    ).ToArray();
    [Void]$termList.Add($term);
} | Out-Null;
# sort by first string length revert
[Void]$termList.Sort([Comparison[String[]]] {
        # right[0].Length - left[0].Length
        return $args[1][0].Length - $args[0][0].Length;
    }
);

$termList | ForEach-Object -Process {
    [String[]]$term = $_;
    # arrange
    [String]$sourceString = $term[0];
    [String]$termString = [String]::Join(
        [Char]12288,
        "$($term[0])($($term[1])|$($term[2]))".ToCharArray()
    );
    [String]$regexString = '(?m)(?i)(?<!(?:`|`[\S\n\r][^`]*?|\[[\w\s\(\)\|]+\]\([^\)]*?|^\[code asset\].*?|<!--label:.*?))';
    # replace
    $content = $content -replace ( $regexString + $sourceString), $termString;
} | Out-Null;
# remove all spaces
$content = $content.Replace([Char]12288, '', [StringComparison]::Ordinal);
# write to file
Set-Content -Path $file -Value $content | Out-Null;

exit 0;
