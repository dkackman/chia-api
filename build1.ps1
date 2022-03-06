Remove-Item ./build -Force -Recurse

mkdir ./build
mkdir ./build/tmp
mkdir ./build/site

$file = "daemon.yaml"
$shortFile = [IO.Path]::GetFileNameWithoutExtension($file)
java -jar ./tools/swagger-codegen-cli.jar generate -l html2 -i ./src/$file -o ./build/tmp/$file `
    -t tools/templates/htmlDocs2 --additional-properties endpoint=$shortFile websocket=true

Copy-Item ./build/tmp/$file/index.html -Destination ./build/site/$shortFile.html
Copy-Item -Path ./build/site/$shortFile.html -Destination ./docs/static/ -Force
