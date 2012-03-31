http = require 'http'
CalFile = require './CalFile'
Listing = require './listing'

calFile = new CalFile()

listing = new Listing('http://cityoftulsa.org/our-city/meeting-agendas/all-agendas.aspx')

listing.events (events) ->
  calFile.createCal(events)
  
# is the file old?
# console.log calFile.isOld()

serv = http.createServer (req, res) ->

  # update file will be served on next request :(
  if calFile.isOld()
    listing.events (events) ->
      calFile.createCal(events)
  
  # serve ics file   
  res.writeHead 200,
    'Content-Type' : 'text/calendar'
  res.write(calFile.getContents(),'binary')
  res.end()

serv.listen(5678, '127.0.0.1')
console.log 'listening'
  
process.on 'exit', (e) ->
  serv.close()
  
process.on 'error', (e) ->
  console.dir(e)