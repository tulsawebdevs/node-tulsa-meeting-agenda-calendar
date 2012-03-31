fs = require 'fs'
moment = require 'moment'
icalendar = require 'icalendar'

module.exports = class CalFile
  constructor: (fileName) ->
    @fileName = fileName if fileName
  fileName: 'test.ics'
  updateDays: 1
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
      return @fileContents = fs.readFileSync @fileName, 'binary'
  getContents: () ->
    return @fileContents || @loadContents()
  isOld: () ->
    stats = fs.statSync @fileName
    if stats.isFile()
      modified = new moment(stats.mtime)
      # days since last modification
      diff = new moment().diff(modified,'days')
      return diff >= @updateDays
    else
      # return true to re-run scrapper
      return true
  createCal: (events) ->
    cal = new icalendar.iCalendar()
    events.forEach (eventObj) ->
      event = new icalendar.VEvent()
      event.setSummary(eventObj.summary || '')
      event.setDescription(eventObj.description || '')
      date = new moment eventObj.date
      event.setDate date.toDate(), date.add('days',1).toDate() 
      cal.addComponent event
      
    @updateFile(cal.toString())
