#= require base.js.coffee
#= require lib/all.js
#= require viewmodels/index.js.coffee

do ->
   IndexViewModel = window.IndexViewModel

   $(document).ready ->
      vm = new IndexViewModel()
      ko.applyBindings(vm)
