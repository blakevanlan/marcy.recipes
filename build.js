#!/usr/bin/env node

const CoffeeScript = require('coffee-script');
CoffeeScript.register();

const Generator = require('./build/generator');
const Path = require('path');
const Utils = require('./build/utils');
const Assets = require('./build/assets');

// Parse for debug option.
const debug = (process.argv.length == 3 && process.argv[2] === '-d');

console.log("\nBuilding assets:\n");

Assets.compileAssets(debug);

console.log("\nGenerating pages:\n");

const filename = Path.join(__dirname, 'recipes/Soy.paprikarecipe');
Utils.readPaprikaRecipeFile(filename, function(err, paprikaRecipe) {
   if (err) throw err;
   var manifest = Generator.generateManifest([paprikaRecipe]);
   Generator.generateHomePage();
   Generator.generateSearchPage();
   Generator.generateRecipePage(paprikaRecipe);
   Generator.generateRecipeSnippet(paprikaRecipe);
   Generator.generateInvertedIndex([paprikaRecipe]);

   console.log('\nDone.');
});
