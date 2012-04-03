jsdom = require "jsdom"

module.exports = class Listing
  jquery: 'http://code.jquery.com/jquery-1.7.1.min.js'

  events: []

  constructor: (@url) ->
    
  metaUrl: (window, a) ->
    a = window.$(a)
    url = a.attr('href')
    type: a.text()
    url: "http://cityoftulsa.org#{url}" unless url.match(/^https?:/)

  eventFromRow: (window, row) ->
    cols  = window.$(row).find('td')
    date:  cols.eq(0).text()
    title: cols.eq(1).text()
    meta:  @metaUrl(window, cols.eq(2).find('a').eq(0))

  events: (callback) ->
    throw new Error('.events() needs a callback') if typeof callback != 'function'
    jsdom.env @url, [@jquery], (err, window) =>
      if err then throw err
      rows = window.$('#agendaList table>tr:not(:first,:last,:nth-child(2))')
      callback (@eventFromRow(window, row) for row in rows ) # when window.$(row).find('td').length == 3

unless module.parent
  listing = new Listing('http://cityoftulsa.org/our-city/meeting-agendas/all-agendas.aspx')
  listing.events (events) ->
    console.log events[0].meta
