#= require lib/all.js
#= require search/inverted-index.js.coffee

do ->
   invertedIndex = window.InvertedIndex

   class SearchBarComponent


   # TODO: figure out template
   ko.components.register("search-bar", 
      viewModel: SearchBarComponent,
      template: "<input",
   )

   window.SearchBarComponent = SearchBarComponent
