#= require lib/all.js
#= require extensions/all.js
#= require data/inverted-index.js.coffee
#= require data/snippet-registry.js.coffee

do ->
   invertedIndex = window.InvertedIndex
   snippetRegistry = window.SnippetRegistry

   class SearchBarComponent
      constructor: (param) ->
         @text = ko.observable().extend({ rateLimit: 100 })
         @text.subscribe(@onTextChange_)
         @callback_ = param.callback
         @currentQuery = null

      onEnter_: =>
         @callback_(@text())

      onTextChange_: (value) =>
         @currentQuery = value
         

   ko.components.register("search-bar", {
      viewModel: SearchBarComponent,
      template:
         "<div class='search-bar'>
            <div class='search-bar__icon'></div>
            <input class='search-bar__input' type='text' placeholder='Search'
               data-bind=\"value: text, valueUpdate: 'afterkeydown',
                  onEnter: {callback: onEnter_, clearAfter: true}\" />
         </div>"
   })

   window.SearchBarComponent = SearchBarComponent
