Fs = require('fs')
InvertedIndex = require('./inverted-index')
Path = require('path')
Pug = require('pug')
Utils = require('./utils')

MAIN_DIRECTORY = Path.join(__dirname, '../docs')
IMAGES_DIRECTORY = Path.join(__dirname, '../docs/images/recipes')
RECIPES_DIRECTORY = Path.join(__dirname, '../docs/recipes')
SNIPPETS_DIRECTORY = Path.join(__dirname, "../docs/snippets")
INVERTED_INDEX_FILENAME = Path.join(__dirname, '../docs/inverted-index.js')

FIELDS_IN_SNIPPET = [
   'name',
   'cook_time',
   'prep_time',
   'servings',
   'categories',
   'source',
   'source_url'
]

# Compiled template functions
indexTemplate = Pug.compileFile(Path.join(__dirname, '../templates/index.pug'))
recipeTemplate = Pug.compileFile(Path.join(__dirname, '../templates/recipe.pug'))
searchTemplate = Pug.compileFile(Path.join(__dirname, '../templates/search.pug'))

renderOptions = {
   basedir: Path.join(__dirname, '../templates')
   isProduction: true
   css: (file) -> return '<link rel="stylesheet" href="/' + file + '.css">'
   js: (file) -> return '<script src="/' + file + '.js"></script>'
}

generateHomePage = ->
   html = indexTemplate(renderOptions);
   filename = Path.join(MAIN_DIRECTORY, "index.html")
   Fs.writeFileSync(filename, html)

   console.log("Generated index.html")

generateSearchPage = ->
   html = searchTemplate(renderOptions);
   filename = Path.join(MAIN_DIRECTORY, "search.html")
   Fs.writeFileSync(filename, html)

   console.log("Generated search.html")

generateRecipePage = (paprikaRecipe) -> 
   standardizedName = paprikaRecipe.standardized_name

   # Write the image file to disk.
   imageFilename = Path.join(IMAGES_DIRECTORY, "#{standardizedName}.jpg")
   Utils.writeBase64Image(imageFilename, paprikaRecipe.photo_data)

   # Generate the recipe page.
   options = Object.assign({}, renderOptions, paprikaRecipe)
   recipeHtml = recipeTemplate(options)
   recipeFilename = Path.join(RECIPES_DIRECTORY, "#{standardizedName}.html")
   Fs.writeFileSync(recipeFilename, recipeHtml)

   console.log("Generated recipes/#{standardizedName}.html")

generateRecipeSnippet = (paprikaRecipe) ->
   standardizedName = paprikaRecipe.standardized_name
   snippet = {
      standardizedName: standardizedName
      local_url: Utils.createLocalPageUrl(standardizedName)
      local_photo_url: Utils.createLocalPhotoUrl(standardizedName)
   }
   for field in FIELDS_IN_SNIPPET
      snippet[field] = paprikaRecipe[field]

   script = "window.SnippetRegistry.loaded('#{standardizedName}', #{JSON.stringify(snippet)});"
   filename = Path.join(SNIPPETS_DIRECTORY, "#{standardizedName}.js")
   Fs.writeFileSync(filename, script)

   console.log("Generated snippets/#{standardizedName}.js")

generateInvertedIndex = (paprikaRecipes) ->
   invertedIndex = InvertedIndex.createInvertedIndex(paprikaRecipes)
   script = "window.InvertedIndex.loaded(#{JSON.stringify(invertedIndex)});"
   Fs.writeFileSync(INVERTED_INDEX_FILENAME, script)

   console.log('Generated inverted_index.js')


module.exports = {
   generateHomePage: generateHomePage
   generateSearchPage: generateSearchPage
   generateRecipePage: generateRecipePage
   generateRecipeSnippet: generateRecipeSnippet
   generateInvertedIndex: generateInvertedIndex
}