fs = require 'fs'
moment = require 'moment'
icalendar = require 'icalendar'
crypto = require 'crypto'

module.exports = class CalFile
  constructor: (@fileName) ->
    
  fileName: 'test.ics'
  
  # Only update calendar file when a day has passed
  updateWhen:
    unit: 'days'
    amount: 1
  
  fileContents: null
  
  fd: null
  
  getFD: () ->
    if(!@fd)
      return @fd = fs.openSync(@fileName, 'w+')
    return @fd
    
  updateFile: (contents) ->
    buffer = new Buffer(contents)
    return fs.writeSync(@getFD(),buffer,0,buffer.length) == buffer.length
    
  loadContents: () ->
    try
      return @fileContents = fs.readFileSync @fileName, 'binary'
    catch e
      return false
      
  getContents: () ->
    return @loadContents() if @isOld() else @fileContents
    
  isOld: () ->
    try
      stats = fs.statSync @fileName
      if stats.isFile()
        modified = new moment(stats.mtime)
        # days since last modification
        diff = new moment().diff(modified,@updateWhen.unit)
        return diff >= @updateWhen.amount
      else
        # return true to re-run scrapper
        return false
    catch e
      return true
      
  createCal: (events) =>
    cal = new icalendar.iCalendar()
    events.forEach (eventObj, i) ->
      # hash it
      secretKey = eventObj.title+"|"+eventObj.date
      uid = crypto.createHmac( 'sha1', secretKey ).update( eventObj.meta[0].url ).digest('base64')
      
      # create a new iCal event
      event = new icalendar.VEvent( uid )
      event.setSummary( eventObj.title || '')
      event.setDescription( eventObj.meta[0].title )
      
      # Add url
      event.addProperty( 'URL;VALUE=URI', eventObj.meta[0].url )
      date = new moment eventObj.date
      
      # event.setDate date.toDate(), date.add('days',1).toDate() 
      event.addProperty('DTSTART;VALUE=DATE', date.format('YYYYMMDD')) #, {type:'DATE'}
      event.addProperty('DTEND;VALUE=DATE', date.add('day',1).format('YYYYMMDD')) #, {type:'DATE'}
      # event.addProperty('SEQUENCE', 6 , {type:'INTEGER'})
      
      cal.addComponent event
      
    @updateFile(cal.toString())
