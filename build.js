#!/usr/bin/env node

const CoffeeScript = require('coffee-script');
CoffeeScript.register();

const Generator = require('./build/generator');
const Path = require('path');
const Fs = require('fs');
const Utils = require('./build/utils');
const Assets = require('./build/assets');

const config = {
   timestamp: Date.now(),
   permanent_categories: [
      'Appetizers',
      'Entrees',
      'Sides',
      'Dessert',
      'Beverages'
   ]
};

console.log("\nReading recipes:\n");

var filenames = Fs.readdirSync(Path.join(__dirname, 'recipes'));
var paprikaRecipes = []
for (var i = 0; i < filenames.length; i++) {
   var fullFilename = Path.join(__dirname, 'recipes', filenames[i]);
   paprikaRecipes.push(Utils.readPaprikaRecipeFile(fullFilename));
}
console.log("Found " + paprikaRecipes.length + " recipes.")

console.log("\nGenerating content:\n");

var manifest = Generator.generateManifest(paprikaRecipes, config);
Generator.generateMostRecentSnippets(manifest, paprikaRecipes, config);
Generator.generateInvertedIndex(paprikaRecipes);
Generator.generateHomePage(config);

for (var i = 0; i < paprikaRecipes.length; i++) {
   Generator.generateRecipePage(paprikaRecipes[i], config);
   Generator.generateRecipeSnippet(paprikaRecipes[i]);
}

console.log("\nBuilding assets:\n");

Generator.generateJsConfig(config);
Assets.compileAssets();

console.log('\nDone.');
