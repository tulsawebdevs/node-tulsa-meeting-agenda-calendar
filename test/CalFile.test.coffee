CalFile = require '../CalFile'
fs = require 'fs'
path = require 'path'
icalendar = require 'icalendar'

# Correctly formatted event object from scrapper
testEvents = [
  {
    title: 'Test Title 1'
    date: '02-05-1980'
    meta:
      type:'AGENDA'
      url: 'http://somewebsite.com/agenda?=1230345'
  }
  {
    title: 'Test Title 2'
    date: '01-25-1986'
    meta:
      type:'NOTICE'
      url: 'http://somewebsite.com/agenda?=198345'
  }
]

testFile = path.resolve( process.cwd(), 'test', 'support', 'tests.ics' )

removeTestFile = (file) ->
  try
    fs.unlinkSync file
  catch e
    
###
  Test cases:
  Adding events shouldn't error
  file should be written
  TODO: New instance of CalFile that interacts with same file should be able to read generated file.
###

describe "CalFile", ->
  cal = null
  
  beforeEach ->
    # Start each test with a new instance of CalFile
    cal = new CalFile(testFile)
    
  afterEach ->
    removeTestFile(testFile)
    
  describe ".getFD()", ->
    fileDescriptor = null
    it "should return", ->
      fileDescriptor = cal.getFD()
      fileDescriptor.should.be.ok
    it "should return a file descriptor number", ->
      console.log "##{fileDescriptor}"
      fileDescriptor.should.be.a('number')
      
  describe ".loadContents()", ->
    it "return an iCal formatted string", ->
      cal.createCal(testEvents)
      contents = cal.loadContents()
      contents.should.be.a('string')
      ical = icalendar.parse_calendar(contents)
      # events = ical.events()
      
    it "should return false if file doesn't exist", ->
      cal = new CalFile('non-written-file.ics')
      cal.loadContents().should.be.false
      
  # describe ".getContents()", ->
  #   it "returns the contents of the file", ->
  #   it "gets latest version of file if its old", ->
      
  describe ".updateFile()", ->
    it "writes to the file", ->
      cal.updateFile('New Calendar Events')
      cal.loadContents().should.equal('New Calendar Events')
      
  describe ".isOld()", ->
    #  (its really old! it hasn't even been created yet!)
    it "should return true if no file present or created", ->
      cal = new CalFile('non-written-file.ics')
      cal.isOld().should.be.true
    # this test may fail on a clone
    it "return true if file is old", ->
      cal = new CalFile path.resolve process.cwd(), 'test', 'support', 'download.ics'
      cal.isOld().should.be.true
    it "return false if file is a directory", ->
      cal = new CalFile(process.cwd())
      cal.isOld().should.be.false
      
  describe ".createCal()", ->
    written = null
    it "shouldn't error when adding events", ->
      ( ->
        written = cal.createCal(testEvents)
      ).should.not.throw()
    it "should confirm file written", ->
      written.should.be.true
      