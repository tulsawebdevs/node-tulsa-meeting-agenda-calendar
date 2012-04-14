Listing = require '../lib/Listing'
should = require 'should'
path = require 'path'

checkErr = (type) ->
  return (err,superfluous) ->
    should.exist(err)
    err.should.be.an.instanceof(Error)
    err.code.should.eql(type)
  
describe "Listing", ->
  describe ".events()", ->
    
    listing = null
    
    before ->
      listing = new Listing path.resolve process.pwd, 'test/support/all-agendas.html'
    
    it "should return an properly formatted events array", (done)->
      listing.events (err, events) ->
        should.not.exist(err, '.events() returned an error')
        events.should.be.an.instanceof(Array, 'returned events needs to be an Array')
        
        # 50 events in page
        events.length.should.eql(50)
        events.forEach (event,i) ->
          event.should.have.keys([ 'title', 'date', 'meta', 'id' ])
          event.meta.should.have.keys(['url', 'type'])
        done()
        
    it "should throw an error if not given a callback", ->
      (() ->
        listing.events('string of sorts')
      ).should.throw()
      (() ->
        listing.events(null)
      ).should.throw()
    
    it "non-existent Local Files should return an File Not Found error", ->
      errListing = new Listing('./test/support/non-existent-file.html')
      errListing.events checkErr('ENOENT')
      
    it "non-existent URLs should return an Not Found error", ->
      errListing = new Listing('http://somewebsitethatsucks.com/nonexistens.html')
      errListing.events checkErr('ENOTFOUND')
