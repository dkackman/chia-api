param(
    $file
)

if (!$file) {
    $file = "daemon.yaml"
}
$shortFile = [IO.Path]::GetFileNameWithoutExtension($file)

# this does swagger-codegen
if ($shortFile -eq "daemon") {
    # need to let the custom codegen template know to use websocket for deamon
    java -jar ./tools/swagger-codegen-cli.jar generate -l html2 -i ./src/$file -o ./build/tmp/$file `
        -t tools/templates/htmlDocs2 --additional-properties endpoint=$shortFile websocket=true
}
else {
    java -jar ./tools/swagger-codegen-cli.jar generate -l html2 -i ./src/$file -o ./build/tmp/$file `
        -t tools/templates/htmlDocs2 --additional-properties endpoint=$shortFile
}
Copy-Item ./build/tmp/$file/index.html -Destination ./build/site/$shortFile.html

# this does redocly
npx redoc-cli build src/$file --output build/redoc/$shortFile.html --options.theme.colors.primary.main=green
