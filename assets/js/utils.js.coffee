do ->
   standardize = (str) ->
      return str.replace(/[\s-_]/g, '-').replace(/["'\/\(\)\\,]/g, '').toLowerCase()

   tokenize = (value) ->
      if value instanceof Array
         value = value.join('-')
      return standardize(value).split('-')

   window.Utils = {
      standardize: standardize
      tokenize: tokenize
   }