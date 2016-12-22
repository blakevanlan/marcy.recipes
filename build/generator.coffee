Fs = require('fs')
InvertedIndex = require('./inverted-index')
Path = require('path')
Pug = require('pug')
Utils = require('./utils')

MAIN_DIRECTORY = Path.join(__dirname, '../docs')
IMAGES_DIRECTORY = Path.join(__dirname, '../docs/images')
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

generateHomePage = ->
   html = indexTemplate();
   filename = Path.join(MAIN_DIRECTORY, "index.html")
   Fs.writeFileSync(filename, html)

   console.log("Generated index.html")

generateSearchPage = ->
   html = searchTemplate();
   filename = Path.join(MAIN_DIRECTORY, "search.html")
   Fs.writeFileSync(filename, html)

   console.log("Generated search.html")

generateRecipePage = (paprikaRecipe) -> 
   standardizedName = Utils.standardize(paprikaRecipe.name)

   # Write the image file to disk.
   imageFilename = Path.join(IMAGES_DIRECTORY, "#{standardizedName}.jpg")
   paprikaRecipe.photo_local_url = createLocalPhotoUrl(standardizedName)
   Utils.writeBase64Image(imageFilename, paprikaRecipe.photo_data)

   # Generate the recipe page.
   recipeHtml = recipeTemplate(paprikaRecipe);
   recipeFilename = Path.join(RECIPES_DIRECTORY, "#{standardizedName}.html")
   Fs.writeFileSync(recipeFilename, recipeHtml)

   console.log("Generated recipes/#{standardizedName}.html")

generateRecipeSnippet = (paprikaRecipe) ->
   standardizedName = Utils.standardize(paprikaRecipe.name)
   snippet = {
      id: standardizedName
      local_url: createLocalPageUrl
      local_photo_url: createLocalPhotoUrl()
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

createLocalPageUrl = (standardizedName) ->
   return "/recipes/#{standardizedName}.html"

createLocalPhotoUrl = (standardizedName) ->
   return "/images/#{standardizedName}.jpg"


module.exports = {
   generateHomePage: generateHomePage
   generateSearchPage: generateSearchPage
   generateRecipePage: generateRecipePage
   generateRecipeSnippet: generateRecipeSnippet
   generateInvertedIndex: generateInvertedIndex
}