#= require base.js.coffee
#= require config.js.coffee
#= require data/most-recent-registry.js.coffee
#= require lib/all.js

do ->
   MostRecentRegistry = window.MostRecentRegistry
   Config = window.Config

   class IndexViewModel
      constructor: ->
         @loading = ko.observable(true)
         @currentFilter = ko.observable("most recent")
         @snippets = ko.observableArray()
         @numberOfColumns = ko.observable(3)
         @columnClass = ko.computed(@columnClassComputed_)
         @snippetColumns = ko.computed(@snippetColumnsComputed_)
         @currentMostRecentPage_ = 0
         @loadPage_(@currentMostRecentPage_)

      onSearch: (search) =>
         @currentFilter("\"#{search}\"")

      onScrolledToBottom: =>
         if !@loading() && @currentMostRecentPage_ < Config.number_of_most_recent_pages - 1
            @currentMostRecentPage_ += 1
            loadPage_(@currentMostRecentPage_)

      loadPage_: (pageNumber) ->
         @loading(true)
         MostRecentRegistry.loadPage pageNumber, (err, snippets) =>
            return if err
            @snippets.push(snippet) for snippet in snippets
            @loading(false)

      columnClassComputed_: =>
         return switch @numberOfColumns()
            when 1 then "columns-one"
            when 2 then "columns-two"
            when 3 then "columns-three"
            when 4 then "columns-four"
            when 5 then "columns-five"
            else "columns-one"

      snippetColumnsComputed_: =>
         numberOfColumns = @numberOfColumns()
         columns = [] 
         for i in [0...@numberOfColumns()] by 1
            columns.push([])
         
         for snippet, index in @snippets()
            columns[index % numberOfColumns].push(snippet)

         return columns


   window.IndexViewModel = IndexViewModel
