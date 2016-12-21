#!/usr/bin/env node

const CoffeeScript = require('coffee-script');
CoffeeScript.register();

const Generator = require('./build/generator');
const Path = require('path');
const Utils = require('./build/utils');
const Assets = require('./build/assets');
const InvertedIndex = require('./build/inverted-index');

console.log("\nBuilding assets:\n")

Assets.compileAssets()

console.log("\nGenerating pages:\n")

const filename = Path.join(__dirname, 'recipes/Soy.paprikarecipe');
Utils.readPaprikaRecipeFile(filename, function(err, paprikaRecipe) {
   if (err) throw err;
   Generator.generateHomePage()
   Generator.generateSearchPage()
   Generator.generateRecipePage(paprikaRecipe)

   console.log(InvertedIndex.generateInvertedIndex([paprikaRecipe]));

   console.log('\nDone.')
});