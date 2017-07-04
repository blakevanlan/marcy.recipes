#= require config.js.coffee
#= require data/snippet-registry.js.coffee

do ->
   Config = window.Config
   SnippetRegistry = window.SnippetRegistry

   class MostRecentRegistry
      constructor: ->
         @pages_ = []
         @outstandingPageLoads_ = []
         @scriptTagsByPageNumber_ = []

      loaded: (pageNumber, snippets) ->
         @pages_[pageNumber] = snippets
         @removeScriptTag_(pageNumber)
         for snippet in snippets
            SnippetRegistry.loaded(snippet.standardized_name, snippet)
         outstandingPageLoad = @outstandingPageLoads_[pageNumber]
         outstandingPageLoad.callback(null, snippets) if outstandingPageLoad

      loadPage: (pageNumber, callback) ->
         page = @pages_[pageNumber]
         if page
            setTimeout ->
               callback(null, page)
            , 0
            return

         # We need to load the page.
         @outstandingPageLoads_.push({
            pageNumber: pageNumber
            callback: callback   
         })

         # Check if we are already loading the snippet.
         return if @scriptTagsByPageNumber_[pageNumber]
         scriptTag = document.createElement('script');
         scriptTag.src = "/most-recent/most-recent-recipes-#{pageNumber}.js?#{Config.timestamp}"
         scriptTag.type = "text/javascript"
         document.getElementsByTagName("head")[0].appendChild(scriptTag)
         @scriptTagsByPageNumber_[pageNumber] = scriptTag      

      removeScriptTag_: (pageNumber) ->
         scriptTag = @scriptTagsByPageNumber_[pageNumber]
         @scriptTagsByPageNumber_[pageNumber] = null
         document.getElementsByTagName("head")[0].removeChild(scriptTag)


   window.MostRecentRegistry = new MostRecentRegistry()
