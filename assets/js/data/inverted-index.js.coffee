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
            results = @searchInvertedIndex_(outstandingQuery.query, outstandingQuery.fields)
            outstandingQuery.callback(null, results)
         @outstandingQueries_ = []

      search: (query, fields, callback) ->
         unless @hasLoaded_()
            @outstandingQueries_.push({
               query: query
               fields: fields
               callback: callback
            })
            return

         results = @searchInvertedIndex_(query, fields)
         setTimeout ->
            callback(null, results)
         , 0

      searchInvertedIndex_: (query, fields) ->
         tokens = Utils.tokenize(query)
         matchingIdsToTotalWeights = {}
         
         # Find all matching id and compute each individual tokens product.
         for token in tokens
            tokenValue = @invertedIndex_[token]
            continue unless tokenValue
            for field in tokenValue.f
               if fields and fields.length and fields.indexOf(field.n) == -1
                  # Filter out fields that are not of the required type.
                  continue
               matchingIdsToTotalWeights[field.id] = [] unless matchingIdsToTotalWeights[field.id]
               product = field.w * (field.o / tokenValue.t)
               matchingIdsToTotalWeights[field.id].push(product)

         # Sum up the products to get an ordering.
         entries = Object.keys(matchingIdsToTotalWeights).map (id) ->
            return {
               id: id
               weight: matchingIdsToTotalWeights[id].reduce(InvertedIndex.sumReduction, 0)
            }

         entries.sort (a, b) ->
            return 1 if a.weight > b.weight
            return -1 if a.weight < b.weight
            return 0

         return entries

      @sumReduction: (accumulator, current) ->
         return accumulator + current


   window.InvertedIndex = new InvertedIndex()
