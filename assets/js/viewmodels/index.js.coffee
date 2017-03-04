#= require base.js.coffee
#= require config.js.coffee
#= require data/most-recent-registry.js.coffee
#= require lib/all.js
#= require utils.js.coffee

do ->
   Config = window.Config
   InvertedIndex = window.InvertedIndex
   MostRecentRegistry = window.MostRecentRegistry
   SnippetRegistry = window.SnippetRegistry
   Utils = window.Utils

   FilterType = {
      MostRecent: 'most-recent'
      Tag: 'tag'
      Search: 'search'
   }
   LeftQuote = "“"
   RightQuote = "”"
   SearchResultsPerPage = 25

   class IndexViewModel
      constructor: ->
         @loading = ko.observable(true)
         @filterType = ko.observable(FilterType.MostRecent)
         @filterValue = ko.observable(null)
         @currentFilterText = ko.computed(@currentFilterTextComputed_)
         @snippets = ko.observableArray()
         @numberOfColumns = ko.observable(3)
         @columnClass = ko.computed(@columnClassComputed_)
         @snippetColumns = ko.computed(@snippetColumnsComputed_)
         @permanentCategories = Config.permanent_categories
         @topCategories = Config.sorted_categories.slice(0, 5)
         @currentMostRecentPage_ = 0
         @currentFilterResults_ = null
         @currentFilterResultsPage_ = 0
         @setup_()

      onSearch: (search) =>
         return if !search or !search.length 
         @filterType(FilterType.Search)
         @filterValue(search)
         @reloadSnippets_()
         @pushHistory_('search', @filterValue())

      onScrolledToBottom: =>
         if !@loading() && @currentMostRecentPage_ < Config.number_of_most_recent_pages - 1
            @currentMostRecentPage_ += 1
            @loadMostRecentPage_(@currentMostRecentPage_)

      onRecipeClicked: (recipeSnippet) =>
         window.location = recipeSnippet.local_url

      onTagClicked: (value) =>
         @filterType(FilterType.Tag)
         @filterValue(value)
         @reloadSnippets_()
         @pushHistory_('tag', @filterValue())
         
      onSortedTagClicked: (value) =>
         @onTagClicked(value.category)

      pushHistory_: (fieldName, value) ->
         if window.history and window.history.pushState
            value = value.replace(/\s/g, '+').toLowerCase()
            url = window.location.href.replace(/\?.*/, "") + "?#{fieldName}=#{value}"
            window.history.pushState(null, '', url)

      setup_: ->
         # Response to popstates.
         window.addEventListener 'popstate', =>
            @loadSnippetsForQuerystring_()

         # Change the number of columns based on the browser width.
         window.addEventListener 'resize', =>
            width = $(window).width()
            columns = switch 
              when width < 400 then 1
              when width < 750 then 2
              when width < 1100 then 3
              else 4
            @numberOfColumns(columns)

         @loadSnippetsForQuerystring_()

      loadSnippetsForQuerystring_: ->
         if window.location.search
            params = Utils.parseQuerystring(window.location.search)
            if params.tag and params.tag.length
               @filterType(FilterType.Tag)
               @filterValue(params.tag)
            else if params.search and params.search.length
               @filterType(FilterType.Search)
               @filterValue(params.search)
         else
            @filterType(FilterType.MostRecent)
            @filterValue(null)

         @reloadSnippets_()               

      reloadSnippets_: ->
         @loading(true)
         @snippets([])
         @loadMostRecentPage_(0) if @filterType() == FilterType.MostRecent
         @loadSnippetsForTag_(@filterValue()) if @filterType() == FilterType.Tag
         @loadSnippetsForSearch_(@filterValue()) if @filterType() == FilterType.Search

      loadMostRecentPage_: (pageNumber) ->
         @loading(true)
         @currentMostRecentPage_ = pageNumber
         MostRecentRegistry.loadPage pageNumber, (err, snippets) =>
            return if err
            @snippets.push(snippet) for snippet in snippets
            @loading(false)

      loadSnippetsForTag_: (tag) ->
         InvertedIndex.searchWithTokens [Utils.standardize(tag)], ['categories'], (err, results) =>
            return if err
            @currentFilterResults_ = results
            @loadNextFilterResults_()

      loadSnippetsForSearch_: (search) ->
         return unless search && search.length
         InvertedIndex.search search, null, (err, results) =>
            return if err
            @currentFilterResults_ = results
            @loadNextFilterResults_()

      loadNextFilterResults_: ->
         @loading(true)
         filterType = @filterType()
         filterValue = @filterValue()
         beginning = @snippets().length
         end = Math.min(@currentFilterResults_.length, @snippets().length + SearchResultsPerPage)
         if end > beginning
            idsToLoad = @currentFilterResults_.slice(beginning, end).map((entry) -> entry.id)
            SnippetRegistry.queryAll idsToLoad, (err, snippets) =>
               return if err
               return if filterType != @filterType() or filterValue != @filterValue()
               @snippets.push(snippet) for snippet in snippets
               @loading(false)

      onFilterValueChange_: (value) =>
         @snippets([])
            
         if value == "most recent"
            @currentMostRecentPage_ = 0
            @loadMostRecentPage_(@currentMostRecentPage_)
            return

         if value.indexOf(LEFT_QUOTE) == 0 && value.indexOf(RIGHT_QUOTE) == value.length - 1
            @loadSnippetsForSearch_(value.substring(1, value.length - 2))
            return

         @loadSnippetsForTag_(value)

      currentFilterTextComputed_: =>
         return "most recent" if @filterType() == FilterType.MostRecent
         value = @filterValue()?.replace('+', ' ')
         return value if @filterType() == FilterType.Tag
         return "#{LeftQuote}#{value}#{RightQuote}" if @filterType() == FilterType.Search
         return null

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
