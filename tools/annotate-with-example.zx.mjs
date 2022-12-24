#!/usr/bin/env zx
//
// This tool takes an example JSON RPC response and the path to a YAML schema, and inserts
// `example` keys in the appropriate `property` fields of the YAML schema. It was used to
// generate the example fields in `src/schemas`.
//
// See https://github.com/google/zx#install for getting zx
//
// cat <<EOF | ./tools/annotate-with-example.zx.mjs src/schemas/network_info.yaml
// {
//     "network_name": "mainnet",
//     "network_prefix": "xch",
//     "success": true
// }
// EOF

const args = argv._

const yamlFile = args[0];
const input = await stdin();

const examplesJson = JSON.parse(
  input.replaceAll(/\s+\/\/.*$/mg, '')
);
const schema = await YAML.parse((await fs.readFile(yamlFile)).toString());

/**
 * @param {object} record
 */
function isRef(record) {
  const keys = Object.keys(record);
  return keys.length === 1 && keys[0] === '$ref';
}

const PathError = Symbol('path error')

/**
 * @param {string[]} path
 * @param {object} record
 */
function get(path, record) {
  // console.debug(`get(${JSON.stringify(path)}, ${JSON.stringify(record)})`)
  if (path.length <= 0) {
    return record;
  }
  const [current, ...rest] = path;
  if (record === null || record === undefined) {
    throw PathError;
  }
  if (!(current in record)) {
    throw PathError;
  }
  return get(rest, record[current]);
}


/**
 * @param {string[]} path
 * @param {object} node
 */
function traverse(path, node) {
  const newNode = {};
  const propertyType = node['type'];
  for (const [branch, leaf] of Object.entries(node)) {
    if (Array.isArray(leaf)) {
      newNode[branch] = leaf.map(item => isRef(item) ? item : traverse([...path, branch], item));
    } else if (typeof leaf === 'object') {
      newNode[branch] = isRef(leaf) ? leaf : traverse([...path, branch], leaf);
      continue;
    }
    newNode[branch] = leaf;
    if (branch === 'type') {
      if (leaf === 'object') {
        continue;
      }
      const translatedPath = path.filter(p => p !== 'properties').map(p => p === 'items' ? '0' : p);
      try {
        const example = get(translatedPath, examplesJson);
        if (['object', 'array'].includes(typeof example) && example !== null && example !== undefined && propertyType === "string") {
          console.warn(`${path.join('.')} example is not primitive.`);
          newNode['example'] = JSON.stringify(example);
        } else {
          newNode['example'] = example;
        }
      } catch(err) {
        if (err === PathError) {
          console.warn(`No example found for ${path.join('.')}`);
        } else {
          throw err;
        }
      }
    }
  }
  return newNode;
}
const rootKeys = Object.keys(schema);
if (rootKeys.length !== 1) {
  throw new Error(`Don't know how to handle multiple root keys on schema.`);
}
const rootKey = rootKeys[0];
const newSchema = { [rootKey]: traverse([], schema[rootKey]) };
const newYamlSchema = YAML.stringify(newSchema, null, 2);
const destFile = yamlFile.replace('.yaml', '.with-examples.yaml');
if (destFile === yamlFile) {
  throw new Error();
}
await fs.writeFile(destFile, newYamlSchema)
console.info(`Wrote to ${destFile}`);
