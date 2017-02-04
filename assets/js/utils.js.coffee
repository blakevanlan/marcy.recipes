do ->
   standardize = (str) ->
      return str.replace(/[\s-_]/g, '-').replace(/["'\/\(\)\\,]/g, '').toLowerCase()

   tokenize = (value) ->
      return [] unless value?.length
      if value instanceof Array
         value = value.join('-')
      return standardize(value).split('-')

   window.Utils = {
      standardize: standardize
      tokenize: tokenize
   }