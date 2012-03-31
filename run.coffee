jsdom = require "jsdom"

url = 'http://cityoftulsa.org/our-city/meeting-agendas/all-agendas.aspx'
jquery = 'http://code.jquery.com/jquery-1.7.1.min.js'

jsdom.env url, [jquery], (err, window) ->
  if err then throw err
  rows = window.$('#agendaList table>tr:not(:first, :last)')
  rows.each (i, row) ->
    cols = window.$(row).find('td')
    date = cols.eq(0).html()
    title = cols.eq(1).html()
    if cols.length == 3
      console.log date, title
