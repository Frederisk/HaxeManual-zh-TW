using namespace System;
using namespace System.Collections.Generic;
using namespace System.Linq;

# file path
[String]$file = Read-Host -Prompt "Enter the file path you want to replace term for";
$file = $file.Trim().Trim('"')
# exists
if ((Get-Item -Path $file).Exists) {
    [String]$content = Get-Content -Path $file -Raw;
    Get-Content -Path .\Terminology.md
    | Select-String -Pattern '^[\sa-z0-9_-]*?\|' -Raw
    | ForEach-Object -Process {
        [IEnumerable[String]]$term = [Enumerable]::Select(
            $_.Split('|'),
            [Func[String, String]] { return $args[0].Trim(); }
        ).ToArray();
        $content = $content.Replace($term[0], "$($term[0])($($term[1])|$($term[2]))", [StringComparison]::OrdinalIgnoreCase);
    }
    # write
    Set-Content -Path $file -Value $content;
}
else {
    Write-Error -Message "File does not exist";
}