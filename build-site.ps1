Remove-Item ./build -Force -Recurse

mkdir ./build

# first mash all the disparate files into 1 file per endpoint
$files = Get-ChildItem .\src\*.yaml -name

mkdir ./build/tmp

foreach ($file in $files)
{
    java -jar ./tools/swagger-codegen-cli.jar generate -l html2 -i ./src/$file -o .\build\tmp\$file `
    -t tools/templates/
}

mkdir ./build/site

foreach ($file in $files)
{
    $shortFile = [IO.Path]::GetFileNameWithoutExtension($file)
    Copy-Item .\build\tmp\$file\index.html -Destination .\build\site\$shortFile.html
}
