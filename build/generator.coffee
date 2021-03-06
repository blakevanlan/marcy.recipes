Fs = require('fs')
InvertedIndex = require('./inverted-index')
Path = require('path')
Pug = require('pug')
Utils = require('./utils')

MAIN_DIRECTORY = Path.join(__dirname, '../docs')
IMAGES_DIRECTORY = Path.join(__dirname, '../docs/images/recipes')
RECIPES_DIRECTORY = Path.join(__dirname, '../docs/recipes')
SNIPPETS_DIRECTORY = Path.join(__dirname, '../docs/snippets')
MOST_RECENT_DIRECTORY = Path.join(__dirname, '../docs/most-recent')
MANIFEST_FILENAME = Path.join(__dirname, '../docs/manifest.json')
INVERTED_INDEX_FILENAME = Path.join(__dirname, '../docs/inverted-index.js')
CONFIG_FILENAME = Path.join(__dirname, '../assets/js/config.js.coffee')

RECIPES_PER_MOST_RECENT_PAGE = 25

# Compiled template functions
indexTemplate = Pug.compileFile(Path.join(__dirname, '../templates/index.pug'))
recipeTemplate = Pug.compileFile(Path.join(__dirname, '../templates/recipe.pug'))

generateManifest = (paprikaRecipes, config) ->
   manifest = JSON.parse(Fs.readFileSync(MANIFEST_FILENAME).toString());
   existingRecipes = manifest.recipes or {}
   recipes = {}
   for paprikaRecipe in paprikaRecipes
      recipe = existingRecipes[paprikaRecipe.standardized_name]
      unless recipe
         recipe = {timestamp: config.timestamp}
      recipes[paprikaRecipe.standardized_name] = recipe

   manifest.recipes = recipes
   Fs.writeFileSync(MANIFEST_FILENAME, JSON.stringify(manifest, null, 3))
   return manifest

generateMostRecentSnippets = (manifest, recipes, config) ->
   recipes = recipes.slice(0)
   recipes.sort (a, b) ->
      timestampA = manifest.recipes[a.standardized_name].timestamp
      timestampB = manifest.recipes[b.standardized_name].timestamp
      return timestampB - timestampA

   index = 0
   snippets = []
   snippetScripts = []
   for recipe, index in recipes
      snippets.push(Utils.createRecipeSnippet(recipe))

      if index == recipes.length - 1 or snippets.length >= RECIPES_PER_MOST_RECENT_PAGE
         pageNumber = Math.floor(index / RECIPES_PER_MOST_RECENT_PAGE)

         script = "window.MostRecentRegistry.loaded('#{pageNumber}', #{JSON.stringify(snippets)});"
         filename = Path.join(MOST_RECENT_DIRECTORY, "most-recent-recipes-#{pageNumber}.js")
         Fs.writeFileSync(filename, script)
         snippetScripts.push(script)
         snippets = []
         config.number_of_most_recent_pages = pageNumber

         console.log("Generated most-recent/most-recent-recipes-#{pageNumber}.js")

   categories = {}
   for recipe, index in recipes
      continue unless recipe.categories
      for category in recipe.categories
         continue if category in config.permanent_categories
         categories[category] = if categories[category] then categories[category] + 1 else 1

   sortedCategoriesArray = []
   for category, numberOfOccurances of categories
      sortedCategoriesArray.push({
         category: category
         num_occurances: numberOfOccurances
      })
   sortedCategoriesArray.sort (a, b) ->
      return 1 if a.num_occurances < b.num_occurances
      return -1 if a.num_occurances > b.num_occurances
      return 0
   config.sorted_categories = sortedCategoriesArray

   return snippetScripts

generateHomePage = (config) ->
   options = {config: config}
   options = Object.assign(options, createRenderOptionsForConfig(config))
   html = indexTemplate(options);
   filename = Path.join(MAIN_DIRECTORY, "index.html")
   Fs.writeFileSync(filename, html)

   console.log("Generated index.html")
   return html

generateRecipePage = (paprikaRecipe, config) -> 
   standardizedName = paprikaRecipe.standardized_name

   # Write the image file to disk.
   if paprikaRecipe.photo_data
      imageFilename = Path.join(IMAGES_DIRECTORY, "#{standardizedName}.jpg")
      Utils.writeBase64Image(imageFilename, paprikaRecipe.photo_data)
   
   # Generate the recipe page.
   options = {config: config, recipe: paprikaRecipe}
   options = Object.assign(options, createRenderOptionsForConfig(config))
   recipeHtml = recipeTemplate(options)
   recipeFilename = Path.join(RECIPES_DIRECTORY, "#{standardizedName}.html")
   Fs.writeFileSync(recipeFilename, recipeHtml)

   console.log("Generated recipes/#{standardizedName}.html")
   return recipeHtml

generateRecipeSnippet = (paprikaRecipe) ->
   standardizedName = paprikaRecipe.standardized_name
   snippet = Utils.createRecipeSnippet(paprikaRecipe)
   script = "window.SnippetRegistry.loaded('#{standardizedName}', #{JSON.stringify(snippet)});"
   filename = Path.join(SNIPPETS_DIRECTORY, "#{standardizedName}.js")
   Fs.writeFileSync(filename, script)

   console.log("Generated snippets/#{standardizedName}.js")
   return script

generateInvertedIndex = (paprikaRecipes) ->
   invertedIndex = InvertedIndex.createInvertedIndex(paprikaRecipes)
   script = "window.InvertedIndex.loaded(#{JSON.stringify(invertedIndex)});"
   Fs.writeFileSync(INVERTED_INDEX_FILENAME, script)

   console.log('Generated inverted_index.js')
   return script

generateJsConfig = (config) ->
   script = "window.Config = #{JSON.stringify(config)}"
   Fs.writeFileSync(CONFIG_FILENAME, script)

   console.log("Generated assets/js/config.js.coffee")
   return script

removeOldAssets = (paprikaRecipes) ->
   standardizedNames = {};
   for paprikaRecipe in paprikaRecipes
      standardizedNames[paprikaRecipe.standardized_name] = true
   
   folders = [IMAGES_DIRECTORY, RECIPES_DIRECTORY, SNIPPETS_DIRECTORY]
   for folder in folders 
      removeOldAssetsFromFolder(standardizedNames, folder)

removeOldAssetsFromFolder = (standardizedNames, path) ->
   filesInFolder = Fs.readdirSync(path)
   for file in filesInFolder
      filename = Path.basename(file).replace(Path.extname(file), '')
      unless standardizedNames[filename]
         Fs.unlinkSync(Path.join(path, file)) 
         console.log("Removed #{Path.join(path, file)}")

createRenderOptionsForConfig = (config) ->
   return {
      basedir: Path.join(__dirname, '../templates')
      isProduction: true
      css: (file) -> return "<link rel=\"stylesheet\" href=\"/#{file}.css?#{config.timestamp}\">"
      js: (file, params = {}) ->
         paramsString = ("#{key}=\"#{value}\"" for key, value of params).join(" ")
         return "<script src=\"/#{file}.js?#{config.timestamp}\" #{paramsString}></script>"
   }


module.exports = {
   generateManifest: generateManifest
   generateMostRecentSnippets: generateMostRecentSnippets
   generateHomePage: generateHomePage
   generateRecipePage: generateRecipePage
   generateRecipeSnippet: generateRecipeSnippet
   generateInvertedIndex: generateInvertedIndex
   generateJsConfig: generateJsConfig
   removeOldAssets: removeOldAssets
}