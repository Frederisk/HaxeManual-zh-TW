function Get-FilePathByIndex {
    param ([Int32]$FileIndex)

    $fileNameArray = @(
        '01-introduction.md',
        '02-types.md',
        '03-type-system.md',
        '04-class-field.md',
        '05-expression.md',
        '06-lf.md',
        '07-compiler-usage.md',
        '08-cr-features.md',
        '09-macro.md',
        '10-std.md',
        '11-haxelib.md',
        '12-target-details.md',
        '13-debugging.md'
    );
    return '.\content\' + $fileNameArray[$FileIndex - 1];
}
