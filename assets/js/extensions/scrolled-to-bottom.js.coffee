#= lib/all.js

do ->
   THRESHOLD = 40

   ko.bindingHandlers["scrolledToBottom"] =
      init: (element, valueAccessor) ->
         $element = $(element)
         handler = ->
            viewportHeight = $element.height()
            contentHeight = 0
            for index, child in $element.children()
               $child = $(child)
               contentHeight = Math.max(contentHeight, $child.position().top + $child.height())
               
            if $element.scrollTop() + viewportHeight >= contentHeight - THRESHOLD
               value = ko.unwrap(valueAccessor())
               value()

         $element.on("scroll", handler)
         ko.utils.domNodeDisposal.addDisposeCallback(element, -> $element.off("scroll", handler))
