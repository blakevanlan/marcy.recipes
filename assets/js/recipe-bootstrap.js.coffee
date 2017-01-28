#= require base.js.coffee
#= require lib/all.js
#= require viewmodels/recipe.js.coffee

do ->
   RecipeViewModel = window.RecipeViewModel

   $(document).ready ->
      vm = new RecipeViewModel()
      ko.applyBindings(vm)
