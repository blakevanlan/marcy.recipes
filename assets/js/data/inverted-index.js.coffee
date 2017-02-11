#= require lib/all.js
#= require utils.js.coffee

do ->
   Utils = window.Utils

   TOKEN_MATCH_THRESHOLD = 0.6

   class InvertedIndex
      constructor: ->
         @outstandingQueries_ = []
         @hasLoaded_ = ko.observable(false)
         @invertedIndex_ = null

      loaded: (invertedIndex) ->
         @hasLoaded_(true)
         @invertedIndex_ = invertedIndex
         for outstandingQuery in @outstandingQueries_
            results = @searchInvertedIndex_(outstandingQuery.tokens, outstandingQuery.fields)
            outstandingQuery.callback(null, results)
         @outstandingQueries_ = []

      search: (query, fields, callback) ->
         @searchWithTokens(Utils.tokenize(query), fields, callback)

      searchWithTokens: (tokens, fields, callback) ->
         unless @hasLoaded_()
            @outstandingQueries_.push({
               tokens: tokens
               fields: fields
               callback: callback
            })
            return

         results = @searchInvertedIndex_(tokens, fields)
         setTimeout ->
            callback(null, results)
         , 0

      searchInvertedIndex_: (tokens, fields) ->
         matchingIdsToTokens = {}
         matchingIdsToTotalWeights = {}
         
         # Find all matching id and compute each individual tokens product.
         for token in tokens
            tokenValue = @invertedIndex_[token]
            continue unless tokenValue
            for field in tokenValue.f
               if fields and fields.length and fields.indexOf(field.n) == -1
                  # Filter out fields that are not of the required type.
                  continue
               # Append the weight of this match.
               matchingIdsToTotalWeights[field.id] = [] unless matchingIdsToTotalWeights[field.id]
               product = field.w * (field.o / tokenValue.t)
               matchingIdsToTotalWeights[field.id].push(product)

               # Record which token was a match.
               matchingIdsToTokens[field.id] = {} unless matchingIdsToTokens[field.id]
               matchingIdsToTokens[field.id][token] = true

         # Filter to only the set of results that matched 60% of the
         finalMatchingIdsToTotalWeights = {}
         threshold = Math.ceil(tokens.length * TOKEN_MATCH_THRESHOLD)
         for id, tokens of matchingIdsToTokens
            if Object.keys(tokens).length >= threshold
               finalMatchingIdsToTotalWeights[id] = matchingIdsToTotalWeights[id]

         # Sum up the products to get an ordering.
         entries = Object.keys(finalMatchingIdsToTotalWeights).map (id) ->
            return {
               id: id
               weight: finalMatchingIdsToTotalWeights[id].reduce(InvertedIndex.sumReduction, 0)
            }

         entries.sort (a, b) ->
            return 1 if a.weight < b.weight
            return -1 if a.weight > b.weight
            return 0

         return entries

      @sumReduction: (accumulator, current) ->
         return accumulator + current


   window.InvertedIndex = new InvertedIndex()
