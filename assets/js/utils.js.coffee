do ->
   standardize = (str) ->
      return str.replace(/[\s-_+]/g, '-').replace(/["'\/\(\)\\,]/g, '').toLowerCase()

   tokenize = (value) ->
      return [] unless value?.length
      if value instanceof Array
         value = value.join('-')
      return standardize(value).split('-')

   parseQuerystring = (querystring) ->
      querystring = querystring.replace('?', '') if querystring.indexOf('?') == 0
      result = {}
      for value in querystring.match(/[\w=$+%@#^()]+/g)
         split = value.split('=')
         result[split[0]] = if split[1].length then split[1] else 'true'
      return result

   window.Utils = {
      standardize: standardize
      tokenize: tokenize
      parseQuerystring: parseQuerystring
   }