# App serves a agenda file in different formats
CalFile = require './CalFile'
Listing = require './Listing'
path = require 'path'
express = require 'express'
RSS = require 'rss'
step = require 'step'
moment = require 'moment'

app = module.exports = express.createServer()

app.configure ->  
  # app.use express.logger ' \033[90m:method\033[0m \033[36m:url\033[0m \033[90m:response-time ms\033[0m'
  
  app.use express.bodyParser()
  # app.use express.methodOverride()
  
app.configure 'development', ->
  app.use express.errorHandler
    dumpExceptions: true
    showStack: true
  
app.configure 'production', ->
  app.use express.errorHandler()
  
# open/create the agenda iCal file
calFile = new CalFile( path.resolve process.pwd, 'data', 'agenda.ics' )

# Get upcoming Agenda items
listing = new Listing('http://cityoftulsa.org/our-city/meeting-agendas/all-agendas.aspx')

lastRun = null

compiled =
  ics: null
  rss: null
  json: null
  
TAevents: null
  
requests = 
  info: (req,res) ->
    res.contentType ".html"
    res.end('<a href="/agenda.json">agenda.json</a>, <a href="/agenda.ics">agenda.ics</a>, <a href="/agenda.rss">agenda.rss</a>')
  format: (req,res) ->
    
    # filter/strip
    format = req.params.format.replace(/[^A-Za-z]/g,'')
    console.log format
    
    step( () ->
      
      # refresh every 12 hours
      if lastRun != null
        diff = new moment().diff(lastRun,'hours')
        console.log diff
        
      if( lastRun is null || diff >= 12 )
        console.log 're-getting listing'
        lastRun = new moment()
        listing.events (returnedEvents) =>
          TAevents = returnedEvents
          @( null, returnedEvents )
          return
        return undefined
      else
        @( null, null )
        return undefined
      
    , (err, events) ->
      
      throw err if err
      if( events != null ) #&& TAevents != null 
        
        # JSON
        compiled.json = events
        
        # Create iCal
        calFile.createCal(events)
        compiled.ics = calFile.getContents()
        
        # Create RSS
        feed = new RSS
          title: "city of Tulsa meeting agendas"
          description: "a feed of upcoming and past city Tulsa meetings"
          feed_url: "tulsa-agenda.jit.su/agenda.rss"
          site_url: "tulsa-agenda.jit.su"
          author: "Tulsa Web Developers"
          
        events.forEach (event) ->
          feed.item
            title: event.title
            description: event.meta.type
            url: event.meta.url
            # guid:
            # author:
            date: event.date
      
        compiled.rss = feed.xml(true)
      
      # set format
      res.contentType ".#{format}"
      
      switch format
        when 'json'
          res.json compiled.json || {}
        when 'ics'    
          res.send compiled.ics || ""
        when 'rss'
          res.send compiled.rss || ""
        # when 'txt'
        # when 'csv'
        # when 'xml'
        else
          res.contentType ".txt"
          res.send "#{format} is not supported yet, sorry. (possibly never)"
          
    )

# Base url should just send the ics file
app.get '/', (req,res) ->
  req.params.format = 'ics'
  requests.format(req,res)

app.get '/readme', (req,res) ->
  requests.info(req,res)

app.get '/agenda.:format?', (req,res) ->
  requests.format(req,res)

process.on 'uncaughtException', (e) ->
  console.dir(e)
  console.dir(e.stack)
  return
  
if (!module.parent)
  app.listen process.env.PORT || 4510
  console.log "Server listening on port #{app.address().port} in #{app.settings.env} mode" if app.address()

module.exports = app
