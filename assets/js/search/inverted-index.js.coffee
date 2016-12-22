#= require lib/all.js
#= require utils.js.coffee

do ->
   Utils = window.Utils

   class InvertedIndex
      constructor: ->
         @outstandingQueries_ = []
         @hasLoaded_ = ko.observable(false)
         @invertedIndex_ = null

      loaded: (invertedIndex) ->
         @hasLoaded_(true)
         @invertedIndex_ = invertedIndex
         for outstandingQuery in @outstandingQueries_
            results = @searchInvertedIndex_(outstandingQuery.query)
            callback(null, results)
         @outstandingQueries_ = []

      search: (query, callback) ->
         unless @hasLoaded_()
            @outstandingQueries_.push({
               query: query
               callback: callback
            })
            return

         results = @searchInvertedIndex_(query)
         setTimeout ->
            callback(null, results)
         , 0

      searchInvertedIndex_: (query) ->
         tokens = Utils.tokenize(query)
         matchingIdsToProducts = {}
         
         # Find all matching id and compute each individual tokens product.
         for token in tokens
            tokenValue = @invertedIndex_[token]
            continue unless tokenValue
            for field in tokenValue.f
               matchingIdsToProducts[field.id] = [] unless matchingIdsToProducts[field.id]
               product = field.w * (field.o / tokenValue.t)
               matchingIdsToProducts[field.id].push(product)

         # Sum up the products to get an ordering.
         entries = Object.keys(matchingIdsToProducts).map (id) ->
            return {
               id: id
               weight: matchingIdsToProducts[id].reduce(InvertedIndex.sumReduction, 0)
            }

         entries.sort (a, b) ->
            return 1 if a.weight > b.weight
            return -1 if a.weight < b.weight
            return 0

         return entries

      @sumReduction: (accumulator, current) ->
         return accumulator + current


   window.InvertedIndex = new InvertedIndex()
