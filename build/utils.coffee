Zlib = require('zlib')
Fs = require('fs')

standardize = (str) ->
   return str.replace(/[\s-_]/g, '-').replace(/["'\/\(\)\\,]/g, '').toLowerCase()

tokenize = (value) ->
   if value instanceof Array
      value = value.join('-')
   return standardize(value).split('-')

readPaprikaRecipeFile = (filename, callback) ->
   gunzip = Zlib.createGunzip()
   inStream = Fs.createReadStream(filename)
   inStream.pipe(gunzip);

   buffer = []
   gunzip.on 'data', (data) -> buffer.push(data.toString())
   gunzip.on 'error', (e) -> callback(e)
   gunzip.on 'end', () ->
      content = null
      try
         content = JSON.parse(buffer.join(''))
      catch e
         return callback(e)
      
      return callback(null, content)

writeBase64Image = (filename, data) ->
   buffer = new Buffer(data, 'base64')
   Fs.writeFileSync(filename, buffer)


module.exports = {
   standardize: standardize
   tokenize: tokenize
   readPaprikaRecipeFile: readPaprikaRecipeFile
   writeBase64Image: writeBase64Image
}
