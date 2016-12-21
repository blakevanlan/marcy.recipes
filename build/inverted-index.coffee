Utils = require('./utils')

KEYS_TO_WEIGHTS = {
   'categories': 10,
   'ingredients': 1,
   'name': 5,
   'notes': 1
}

###
# Inverted index structure:
#   {
#     "<token>": {
#       total_occurrences: <number of total occurences>
#       fields: [
#         id: <document id>
#         weight: <weight of this reference>
#         occurrences: <number of occurences in this field>
#       ]
#     }
#   }
###

generateInvertedIndex = (paprikaRecipes) ->
   invertedIndex = {}
   
   # Tokenize each field and record the tokens in the inverted index.
   for key, weight of KEYS_TO_WEIGHTS
      for paprikaRecipe in paprikaRecipes
         standardizedName = Utils.standardize(paprikaRecipe.name)
         tokens = Utils.tokenize(paprikaRecipe[key])
         appendTokensToInvertedIndex(invertedIndex, standardizedName, tokens, weight)

   return invertedIndex
   
appendTokensToInvertedIndex = (invertedIndex, id, tokens, weight) ->
   tokensToOccurrences = {}
   
   # Dedup token occurences.
   for token in tokens
      if token && token.length
         tokensToOccurrences[token] = 1 + (tokensToOccurrences[token] || 0)
   
   # Add each token reference to the inverted index.
   for token, occurrences of tokensToOccurrences
      unless invertedIndex[token]
         invertedIndex[token] = {
            total_occurrences: 0
            fields: []
         }
      tokenValue = invertedIndex[token]
      tokenValue.total_occurrences += tokensToOccurrences[token]
      tokenValue.fields.push({
         weight: weight
         occurrences: tokensToOccurrences[token]
      })

   return invertedIndex



module.exports = {
   generateInvertedIndex: generateInvertedIndex
}

searchInvertedIndex = (tokens, invertedIndex) ->
   matchingIdsToProducts = {}
   
   # Find all matching id and compute each individual tokens product.
   for token in tokens
      tokenValue = invertedIndex[token]
      continue unless tokenValue
      for field in tokenValue.fields
         matchingIdsToProducts[field.id] = [] unless matchingIdsToProducts[field.id]
         product = field.weight * (field.occurrences / tokenValue.total_occurrences)
         matchingIdsToProducts[field.id].push(product)

   # Sum up the products to get an ordering.
   entries = Object.keys(matchingIdsToProducts).map (id) ->
      return {
         id: id
         weight: matchingIdsToProducts[id].reduce(sumReduction, 0)
      }

   entries.sort (a, b) ->
      return 1 if a.weight > b.weight
      return -1 if a.weight < b.weight
      return 0

   return entries

sumReduction = (accumulator, current) ->
   return accumulator + current

