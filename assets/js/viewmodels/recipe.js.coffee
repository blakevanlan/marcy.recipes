#= require base.js.coffee
#= require config.js.coffee
#= require data/most-recent-registry.js.coffee
#= require lib/all.js

do ->
   Config = window.Config
   MostRecentRegistry = window.MostRecentRegistry

   class RecipeViewModel
      constructor: ->
         @recentRecipeSnippets = ko.observableArray()
         @permanentCategories = Config.permanent_categories
         @topCategories = Config.sorted_categories.slice(0, 5)
         @currentRecipeName_ = parseCurrentRecipeStandarizedName_();
         @setup_()

      onSearch: (search) ->
         window.location.href = "/index.html?search=#{search.replace(/\s/g, '+').toLowerCase()}"
      
      onTagClicked: (value) =>
         window.location.href = "/index.html?tag=#{value.replace(/\s/g, '+').toLowerCase()}"
         
      onSortedTagClicked: (value) =>
         @onTagClicked(value.category)

      setup_: ->
         MostRecentRegistry.loadPage 0, (err, snippets) =>
            return if err
            for snippet in snippets
               continue if snippet.standardized_name == @currentRecipeName_
               continue unless snippet.local_photo_url
               @recentRecipeSnippets.push(snippet)
               break if @recentRecipeSnippets().length >= 4

      parseCurrentRecipeStandarizedName_ = ->
         regex = /recipes\/([\w-']+)\.html/
         match = regex.exec(window.location.href)
         if match && match.length == 2
            return match[1]
         return ""


   window.RecipeViewModel = RecipeViewModel
