const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');
var _ = require('lodash');

const srcPath = path.join(__dirname, '../build/bundle');
const outPath = path.join(__dirname, '../build');

fs.readdir(srcPath, function (err, files) {
    if (err) {
        return console.log(`Unable to scan directory: ${err}`);
    }
    const helpMap = {};
    // get all the yaml files
    files.filter(file => file.includes('.yaml')).forEach(function (file) {
        const name = file.replace('.yaml', '');
        helpMap[name] = flattenSpec(file);
    });

    fs.writeFileSync(path.join(outPath, 'help.json'), JSON.stringify(helpMap, null, 2));
});

function flattenSpec(file) {
    const yaml = readFile(file);
    const endpoint = {};

    // get all the paths from the spec. each one is a command
    Object.entries(_.get(yaml, 'paths', {})).forEach(function ([key, value]) {
        const help = {};

        const command = key.slice(1); //trim leading '/'
        help.summary = _.get(value, 'post.summary', 'no help available');

        // get all the input params that are in the request body
        const params = _.get(value, 'post.requestBody.content.application/json.schema.properties', {});
        fixUpParams(params);
        help.params = params;

        endpoint[command] = help;
    });

    return endpoint;
}

function readFile(file) {
    return yaml.load(
        fs.readFileSync(path.join(srcPath, file), 'utf8')
    );
}

function fixUpParams(params) {
    // strip out any unresolved $ref properties
    // not needed with fully dereffed spec files
    for (const property in params) {
        for (const subProperty in params[property]) {
            if (subProperty === '$ref') { // the $ref forks up the json
                params[property] = '[object]';
            }
        }
    }
}