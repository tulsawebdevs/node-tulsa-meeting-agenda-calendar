jsdom = require "jsdom"
url = require 'url'
qs = require 'qs'

module.exports = class Listing
  jquery: 'http://code.jquery.com/jquery-1.7.1.min.js'
  
  events: []
  
  constructor: (@url) ->
  
  metaUrl: (window, a) ->
    metaUrl = a.attr('href')
    type: a.text()
    url: "http://cityoftulsa.org#{metaUrl}" unless metaUrl.match(/^https?:/)
    
  eventFromRow: (window, row) ->
    cols  = window.$(row).find('td')
    a = window.$(cols.eq(2).find('a').eq(0))
    date: cols.eq(0).text()
    title: cols.eq(1).text()
    id: qs.parse( url.parse(a.attr('href')).query ).ID
    meta: @metaUrl(window, a)
    
  events: (callback) ->
    throw new Error('.events() needs a callback') if typeof callback != 'function'
    jsdom.env @url, [@jquery], (err, window) =>
      return callback(err, null) if err
      try
        rows = window.$('#agendaList table>tr:not(:first,:last,:nth-child(2))')
        callback( null, @eventFromRow(window, row) for row in rows when window.$(row).find('td').length == 3 )
      catch err
        callback err, null

unless module.parent
  listing = new Listing('http://cityoftulsa.org/our-city/meeting-agendas/all-agendas.aspx')
  listing.events (events) ->
    console.log events[0]
