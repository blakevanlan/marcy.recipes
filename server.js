#!/usr/bin/env node

const CoffeeScript = require('coffee-script');
CoffeeScript.register();

const Express = require('express');
const Path = require('path');
const Fs = require('fs');
const Utils = require('./build/utils');

const app = Express();

// Settings
app.set('view engine', 'pug');
app.set('view options', {layout: false});
app.set('templates', Path.join(__dirname, 'templates'));
app.set('views', Path.join(__dirname, 'templates'));

app.use(require('connect-assets')({
   sourceMaps: false
}));

app.get('/', function(req, res, next) {
   res.render('index');
});

app.get('/recipes/:standardized_recipe_name', function(req, res, next) {
   var recipeFilenames = Fs.readdirSync(Path.join(__dirname, 'recipes'));
   var paramStandardizedName = req.params.standardized_recipe_name.replace('.html', '')
   for (var i = 0; i < recipeFilenames.length; i++) {
      standardizedName = Utils.standardize(Path.basename(recipeFilenames[i], '.paprikarecipe'));
      if (standardizedName == paramStandardizedName) {
         var filename = Path.join(__dirname, 'recipes', recipeFilenames[i]);
         Utils.readPaprikaRecipeFile(filename, function(err, paprikaRecipe) {
            res.render('recipe', paprikaRecipe);
         });
         return;
      }
   }
   throw Error('Unknown recipe name: ' + req.params.standardized_recipe_name);
});

// Serve the images.
app.use(Express.static(Path.join(__dirname, 'docs')))

const http = require('http');
const port = process.env.PORT || 5000;

http.createServer(app).listen(port, function () {
   console.log('marcy.recipes listening on ' + port);
});
