Path = require('path')
Utils = require('./utils')

FIELDS_TO_WEIGHTS = {
   'categories': 10,
   'ingredients': 1,
   'name': 5,
   'notes': 1
}

FIELDS_TO_ANALYZERS = {
   'categories': Utils.standardizeToken,
   'ingredients': Utils.tokenize,
   'name': Utils.tokenize,
   'notes': Utils.tokenize,
}

###
# Inverted index structure:
#   {
#     "<token>": {
#       t: <number of total occurences>
#       f: [
#         {
#           id: <document id>
#           n: <name of the field> 
#           w: <weight of this reference>
#           o: <number of occurences in this field>
#         },
#         ...
#       ]
#     }
#   }
###

createInvertedIndex = (paprikaRecipes) ->
   invertedIndex = {}
   
   # Tokenize each field and record the tokens in the inverted index.
   for field, weight of FIELDS_TO_WEIGHTS
      for paprikaRecipe in paprikaRecipes
         standardizedName = Utils.standardize(paprikaRecipe.name)
         analyzer = FIELDS_TO_ANALYZERS[field] || Utils.tokenize
         tokens = analyzer(paprikaRecipe[field])
         appendTokensToInvertedIndex(invertedIndex, standardizedName, field, tokens, weight)

   return invertedIndex

appendTokensToInvertedIndex = (invertedIndex, id, field, tokens, weight) ->
   tokensToOccurrences = {}
   
   # Dedup token occurences.
   for token in tokens
      if token && token.length
         tokensToOccurrences[token] = 1 + (tokensToOccurrences[token] || 0)
   
   # Add each token reference to the inverted index.
   for token, occurrences of tokensToOccurrences
      unless invertedIndex[token]
         invertedIndex[token] = {
            t: 0
            f: []
         }
      tokenValue = invertedIndex[token]
      tokenValue.t += tokensToOccurrences[token]
      tokenValue.f.push({
         id: id
         n: field
         w: weight
         o: tokensToOccurrences[token]
      })

   return invertedIndex


module.exports = {
   createInvertedIndex: createInvertedIndex
}
