Fs = require('fs')
Path = require('path')
Pug = require('pug')
Utils = require('./utils')

MAIN_DIRECTORY = Path.join(__dirname, '../docs')
IMAGES_DIRECTORY = Path.join(__dirname, '../docs/images')
RECIPES_DIRECTORY = Path.join(__dirname, '../docs/recipes')

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
   standardizeName = Utils.standardize(paprikaRecipe.name)

   # Write the image file to disk.
   imageFilename = Path.join(IMAGES_DIRECTORY, "#{standardizeName}.jpg")
   paprikaRecipe.photo_local_url = "/images/#{standardizeName}.jpg"
   Utils.writeBase64Image(imageFilename, paprikaRecipe.photo_data)

   # Generate the recipe page.
   recipeHtml = recipeTemplate(paprikaRecipe);
   recipeFilename = Path.join(RECIPES_DIRECTORY, "#{standardizeName}.html")
   Fs.writeFileSync(recipeFilename, recipeHtml)

   console.log("Generated recipes/#{standardizeName}.html")


module.exports = {
   generateHomePage: generateHomePage
   generateSearchPage: generateSearchPage
   generateRecipePage: generateRecipePage
}