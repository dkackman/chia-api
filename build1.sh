#!/bin/sh

file="$1"

if [ -z $file ]; then
    file="daemon.yaml"
fi
shortFile="${file%.*}"

mkdir -p ./build/tmp

# this does swagger-codegen
if [ $shortFile == "daemon" ]; then
    # need to let the custom codegen template know to use websocket for deamon
    java -jar ./tools/swagger-codegen-cli.jar generate -l html2 -i ./src/$file -o ./build/tmp/$file \
        -t ./tools/templates/htmlDocs2 --additional-properties endpoint=$shortFile websocket=true --template-engine "mustache"
else
    java -jar ./tools/swagger-codegen-cli.jar generate -l html2 -i "./src/$file" -o "./build/tmp/$file" \
        -t ./tools/templates/htmlDocs2 --additional-properties endpoint="$shortFile" --template-engine "mustache"
fi
if [ $? -ne 0 ]; then
  echo "Swagger docs generation failed" 1>&2
  exit 1
fi

mkdir -p "./build/site"
cp "./build/tmp/$file/index.html" "./build/site/$shortFile.html"

# this does redocly
npx redoc-cli build "src/$file" --output "build/redoc/$shortFile.html" --options.theme.colors.primary.main=green
