#= lib/all.js

do ->
   ko.bindingHandlers["onEnter"] = 
      "init": (element, valueAccessor) ->
         accessor = ko.unwrap(valueAccessor())
         callback = ko.unwrap(accessor.callback)
         clearAfter = !!ko.unwrap(accessor.clearAfter)
         handler = (e) ->
            keyCode = if e.which then e.which else e.keyCode
            if keyCode == 13
               value = $(element).val()
               callback(value)
               # Clear input
               if clearAfter == true
                  $(element).val("") 

         $el = $(element)
         $el.on('keypress', handler)
         ko.utils.domNodeDisposal.addDisposeCallback element, ->
            $el.off('keypress', handler)
