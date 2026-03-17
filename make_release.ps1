$destinationPath = "C:\Users\$env:USERNAME\AppData\Roaming\Balatro\Mods\SilkTouch"

$excludeFolders = @(".git", ".vscode")
$excludeFiles = @(".gitattributes", ".gitignore", "make_release.ps1")

robocopy . "$destinationPath" /E /XD $excludeFolders /XF $excludeFiles /R:1 /W:1