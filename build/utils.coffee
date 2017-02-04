Zlib = require('zlib')
Fs = require('fs')

FIELDS_IN_SNIPPET = [
   'standardized_name',
   'name',
   'cook_time',
   'prep_time',
   'servings',
   'categories',
   'source',
   'source_url',
   'local_url',
   'local_photo_url'
]

standardize = (str) ->
   return str unless str
   firstSegment = str.split('\n')[0]
   return firstSegment.replace(/[\s-_]/g, '-').replace(/["'\/\(\)\\,]/g, '').toLowerCase()

tokenize = (value) ->
   return [] unless value?.length
   if value instanceof Array
      value = value.join('-')
   return standardize(value).split('-')

readPaprikaRecipeFile = (filename) ->
   buffer = Fs.readFileSync(filename)
   content = JSON.parse(Zlib.gunzipSync(buffer))
   content.standardized_name = standardize(content.name)
   content.local_url = createLocalPageUrl(content.standardized_name)
   content.local_photo_url = createLocalPhotoUrl(content.standardized_name) if content.photo_data
   return content

writeBase64Image = (filename, data) ->
   buffer = new Buffer(data, 'base64')
   Fs.writeFileSync(filename, buffer)

createIndexPageRenderOptions = (paprikaRecipes) ->
   return {
      paprikaRecipes: paprikaRecipes
   }

createLocalPageUrl = (standardizedName) ->
   return "/recipes/#{standardizedName}.html"

createLocalPhotoUrl = (standardizedName) ->
   return "/images/recipes/#{standardizedName}.jpg"

createRecipeSnippet = (paprikaRecipe) ->
   snippet = {}
   for field in FIELDS_IN_SNIPPET
      snippet[field] = paprikaRecipe[field]
   return snippet


module.exports = {
   standardize: standardize
   tokenize: tokenize
   readPaprikaRecipeFile: readPaprikaRecipeFile
   writeBase64Image: writeBase64Image
   createLocalPageUrl: createLocalPageUrl
   createLocalPhotoUrl: createLocalPhotoUrl
   createRecipeSnippet: createRecipeSnippet
}
