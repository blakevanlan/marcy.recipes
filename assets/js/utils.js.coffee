do ->
   standardize = (str) ->
      return str unless str
      firstSegment = str.split('\n')[0]
      return firstSegment.replace(/[\s-_\n&]+/g, '-').replace(/["'\/\(\)\\,:?!^%#@*]/g, '')
            .replace(/[-]+/g, '-').replace(/-$/, '').toLowerCase()

   tokenize = (value) ->
      return [] unless value?.length
      if value instanceof Array
         value = value.join('-')
      return standardize(value).split('-')

   parseQuerystring = (querystring) ->
      querystring = querystring.replace('?', '') if querystring.indexOf('?') == 0
      result = {}
      for value in querystring.match(/[\w=$+%@#^()-]+/g)
         split = value.split('=')
         if split[1] and split[1].length 
            result[split[0]] = split[1].replace(/\+/g, ' ')
         else
            result[split[0]] = true
      return result

   window.Utils = {
      standardize: standardize
      tokenize: tokenize
      parseQuerystring: parseQuerystring
   }