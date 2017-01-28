#= require lib/all.js
#= require extensions/all.js
#= require search/inverted-index.js.coffee
#= require search/snippet-registry.js.coffee

do ->
   invertedIndex = window.InvertedIndex
   snippetRegistry = window.SnippetRegistry

   class SearchBarComponent
      constructor: (param) ->
         @text = ko.observable().extend({ rateLimit: 100 })
         @text.subscribe(@onTextChange_)
         @callback_ = param.callback
         @autocompleteSnippets = ko.observableArray()
         @currentQuery = null

      onEnter_: =>
         @callback_(@text())

      onTextChange_: (value) =>
         @currentQuery = value
         @autocompleteSnippets.removeAll()
         return if !value or value.length < 1

         invertedIndex.search value, (err, entries) =>
            return if err or @currentQuery != value
            for entry in entries
               snippetRegistry.query entry.id, (err, snippets) =>
                  return if err or @currentQuery != value
                  @autocompleteSnippets.push(snippets[0])


   ko.components.register("search-bar", {
      viewModel: SearchBarComponent,
      template:
         "<div class='search-bar'>
            <div class='search-bar__icon'></div>
            <input class='search-bar__input' type='text' placeholder='Search'
               data-bind=\"value: text, valueUpdate: 'afterkeydown',
                  onEnter: {callback: onEnter_, clearAfter: true}\" />
            <div class='search-bar__autocomplete' data-bind='foreach: autocompleteSnippets'>
               <a class='search-bar__autocomplete-result'
                  data-bind='text: name, attr: { href: local_url }'></a>
            </div>
         </div>"
   })

   window.SearchBarComponent = SearchBarComponent
