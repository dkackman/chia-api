$files = Get-ChildItem .\src\*.yaml -name

foreach ($file in $files) {
    ./build1.ps1 -file $file
}
