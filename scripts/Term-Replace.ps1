using namespace System.Collections.Generic;
using namespace System.Linq;

$file = Read-Host -Prompt "Enter the file you want to replace term for" | Get-Item;
if ($file.Exists) {
    $content = Get-Content -Path $file -Raw;

    $terms = [List[String[]]]::new();
    Get-Content -Path .\Terminology.md | ForEach-Object {
        if ($_ -match '^[a-zA-Z0-9\s]*?\|') {
            $terms.Add([Enumerable]::Select(($_.Split('|')), [Func[String, String]] { $args[0].Trim() }));
            # $terms.Add($_.Split(' | '));
        }
    }

    $terms | ForEach-Object {
        $content = $content.Replace($_[0], "$($_[1])($($_[0]),$($_[2]))");
    }
    Set-Content -Path $file -Value $content;
}