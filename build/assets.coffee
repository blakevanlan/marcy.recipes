Fs = require('fs')
Path = require('path')
ChildProcess = require('child_process');

CONNECT_ASSETS_EXECUTABLE = Path.join(__dirname, '../node_modules/.bin/connect-assets')
BUILT_ASSET_DIRECTORY = Path.join(__dirname, '../builtAssets');
ASSET_DIRECTORY = Path.join(__dirname, '../docs');

ASSET_FILENAMES = [
   'main.css',
   'index-bootstrap.js'
   'recipe-bootstrap.js'
   'search-bootstrap.js'
]

compileAssets = -> 
   ChildProcess.execFileSync('rm', ['-rf', BUILT_ASSET_DIRECTORY])
   ChildProcess.execFileSync(CONNECT_ASSETS_EXECUTABLE, {stdio: [0, 1, 2]})
   manifest = require(Path.join(BUILT_ASSET_DIRECTORY, 'manifest.json'))
   
   for filename in ASSET_FILENAMES
      actualFilename = manifest.assets[filename]
      from = Path.join(BUILT_ASSET_DIRECTORY, actualFilename)
      to = Path.join(ASSET_DIRECTORY, filename)
      Fs.createReadStream(from).pipe(Fs.createWriteStream(to))


module.exports = {
   compileAssets: compileAssets
}
