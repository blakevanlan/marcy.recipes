#= require config.js.coffee

do ->
   Config = window.Config

   class SnippetRegistry
      constructor: ->
         @snippetsById_ = {}
         @outstandingQueries_ = []
         @scriptTagsById_ = {}

      loaded: (id, snippet) ->
         @snippetsById_[id] = snippet

         remainingQueries = []
         for outstandingQuery in @outstandingQueries_
            # Call the callback if all of the snippets have loaded.
            snippets = @queryAllSync(outstandingQuery.ids)
            if snippets
               outstandingQuery.callback(null, snippets)
            else
               remainingQueries.push(outstandingQuery)

         @outstandingQueries_ = remainingQueries
         @removeScriptTag_(id)

      query: (id, callback) ->
         @queryAll([id], callback)

      queryAll: (ids, callback) ->
         snippets = @queryAllSync(ids)
         if snippets
            setTimeout ->
               callback(null, snippets)
            , 0
            return

         # We need to load the snippet.
         @outstandingQueries_.push({
            ids: ids
            callback: callback
         })
         @loadSnippets_(id) for id in ids         
      
      queryAllSync: (ids) ->
         snippets = []
         for id in ids
            snippet = @snippetsById_[id]
            if snippet
               snippets.push(snippet)
            else
               return null
         return snippets

      loadSnippets_: (id) ->
         # Check if we are already loading the snippet.
         return if @scriptTagsById_[id]
         scriptTag = document.createElement('script');
         scriptTag.src = "/snippets/#{id}.js?#{Config.timestamp}"
         scriptTag.type = "text/javascript"
         document.getElementsByTagName("head")[0].appendChild(scriptTag)
         @scriptTagsById_[id] = scriptTag

      removeScriptTag_: (id) ->
         scriptTag = @scriptTagsById_[id]
         if scriptTag
            @scriptTagsById_[id] = null
            document.getElementsByTagName("head")[0].removeChild(scriptTag)


   window.SnippetRegistry = new SnippetRegistry()
