http = require 'http'
CalFile = require './CalFile'

calFile = new CalFile()
  
# is the file old?
# console.log calFile.isOld()
# console.log calFile.createCal()

serv = http.createServer (req, res) ->
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