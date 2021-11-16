using namespace System;
using namespace System.Collections.Generic;
using namespace System.Linq;
using namespace System.Text;

# file path
[String]$file = Read-Host -Prompt "Enter the file path you want to replace term for";
$file = $file.Trim().Trim('"')
# exists
if ((Get-Item -Path $file).Exists) {
    # create terms list
    [List[String[]]]$terms = [List[String[]]]::new();
    Get-Content -Path .\Terminology.md
    | Select-String -Pattern '^[\sa-z0-9_-]*?\|' -Raw
    | ForEach-Object -Process {
        $terms.Add(
            [Enumerable]::Select(
                $_.Split('|'),
                [Func[String, String]] { $args[0].Trim() }
            )
        );
    }
    # replace
    [String]$content = Get-Content -Path $file -Raw;
    # [StringBuilder]$builder = [StringBuilder]::new($content);
    $terms | ForEach-Object -Process {
        # [Void]$builder.Replace($_[0], "$($_[0])($($_[1])|$($_[2]))", [StringComparison]::OrdinalIgnoreCase);
        $content = $content.Replace($_[0], "$($_[0])($($_[1])|$($_[2]))", [StringComparison]::OrdinalIgnoreCase);
    }
    # write
    # Set-Content -Path $file -Value $builder.ToString();
    Set-Content -Path $file -Value $content;
}
else {
    Write-Host -Object "File does not exist" -ErrorAction;
}