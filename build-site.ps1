Remove-Item ./build -Force -Recurse

mkdir ./build
mkdir ./build/tmp
mkdir ./build/site

$files = Get-ChildItem .\src\*.yaml -name

foreach ($file in $files)
{
    $shortFile = [IO.Path]::GetFileNameWithoutExtension($file)
    java -jar ./tools/swagger-codegen-cli.jar generate -l html2 -i ./src/$file -o .\build\tmp\$file `
        -t tools/templates/htmlDocs2 --additional-properties endpoint=$shortFile
    Copy-Item .\build\tmp\$file\index.html -Destination .\build\site\$shortFile.html
}
