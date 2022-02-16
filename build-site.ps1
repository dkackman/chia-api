Remove-Item ./build -Force -Recurse
mkdir ./build

# first mash all the disparate files into 1 file per endpoint
$files = Get-ChildItem .\src\*.yaml -name

# foreach ($file in $files)
# {
#    swagger-cli bundle .\src\$file -t yaml -o .\build\$file
# }

mkdir ./build/tmp

foreach ($file in $files)
{
    java -jar ./tools/swagger-codegen-cli.jar generate -l html2 -i ./src/wallet.yaml -o .\build\tmp\$file
}

mkdir ./build/site

foreach ($file in $files)
{
    $shortFile = [IO.Path]::GetFileNameWithoutExtension($file)
    Copy-Item .\build\tmp\$file\index.html -Destination .\build\site\$shortFile.html
}

New-Item .\build\site\index.html -ItemType File
$html = @"
<html><head>
<meta http-equiv='X-UA-Compatible' content='IE=edge' />
<title>Chia RPC</title>
<meta name='viewport' content='width=device-width, initial-scale=1.0'>
<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
<meta charset='UTF-8' />
</head><body><div><ul>
"@

foreach ($file in $files)
{
    $shortFile = [IO.Path]::GetFileNameWithoutExtension($file)
    $a = "<li><a href='./$shortFile.html'>$shortfile</a></li>"
    $html += $a
}

$html += "</ul></div></body></html>"

Set-Content .\build\site\index.html $html
