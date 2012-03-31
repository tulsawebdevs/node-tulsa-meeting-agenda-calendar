phantom = require 'phantom'

url = 'http://cityoftulsa.org/our-city/meeting-agendas/all-agendas.aspx'
jquery = 'http://code.jquery.com/jquery-1.7.1.min.js'

getEvents = ->
  rows = $('#agendaList tbody>tr:not(:first,:last,:nth-child(2))')
  rows.each (i, row) ->
    cols = $(row).find('td')
    date = cols.eq(0).html()
    title = cols.eq(1).html()
    #if cols.length == 3
      #console.log date, title
  console.log $('#agendaList tbody>tr:first-child table').html()
  nextLink = $('#agendaList tbody>tr:first-child table td:has(span)+td').find('a')
  console.log "loading page #{nextLink.html()}"
  nextLink.click()

phantom.create (ph) ->
  ph.createPage (page) ->
    page.set 'onConsoleMessage', (msg) -> console.log msg
    page.set 'onAlert', (msg) -> console.log 'alert', msg
    page.set 'onError', (msg, trace) ->
      console.log msg
      console.log(item.file, item.line) for item in trace
    console.log 'loading page'
    page.open url, (status) ->
      ph.exit() unless status == 'success'
      console.log 'page loaded'
      console.log 'including jquery'
      page.includeJs "http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js", ->
        console.log 'jquery included'
        processPage page
        # ph.exit()

processPage = (page) ->
  page.evaluate getEvents, (result) ->
    setTimeout (-> processPage page), 2000
