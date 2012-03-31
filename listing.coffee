jsdom = require "jsdom"

class Listing
  jquery: 'http://code.jquery.com/jquery-1.7.1.min.js'

  events: []

  constructor: (@url) ->

  metaUrl: (window, a) ->
    a = window.$(a)
    url = a.attr('href')
    url = "http://cityoftulsa.org#{url}" unless url.match(/^https?:/)
    title: a.html()
    url: url

  eventFromRow: (window, row) ->
    cols  = window.$(row).find('td')
    date:  cols.eq(0).html()
    title: cols.eq(1).html()
    meta:  (@metaUrl(window, a) for a in cols.eq(2).find('a'))

  events: (callback) ->
    jsdom.env @url, [@jquery], (err, window) =>
      if err then throw err
      rows = window.$('#agendaList table>tr:not(:first,:last,:nth-child(2))')
      callback (@eventFromRow(window, row) for row in rows when window.$(row).find('td').length == 3)

module.exports = Listing

unless module.parent
  listing = new Listing('http://cityoftulsa.org/our-city/meeting-agendas/all-agendas.aspx')
  listing.events (events) ->
    console.log events[0].meta
