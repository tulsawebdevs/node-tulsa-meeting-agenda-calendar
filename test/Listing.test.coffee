Listing = require '../Listing'

describe "Listing", ->

  listing = null
  
  before ->
    listing = new Listing('./test/support/all-agendas.html')
    
  describe ".events()", ->
    it "should return an properly formatted events array", (done)->
      listing.events (events) ->
        events.should.be.an.instanceof(Array)
        events.forEach (event,i) ->
          event.should.have.keys([ 'title', 'date', 'meta' ])
          event.meta.should.have.keys(['url', 'type'])
        done()
    it "should throw an error if not given a callback", ->
      (() ->
        listing.events('string of sorts')
      ).should.throw()
      (() ->
        listing.events(null)
      ).should.throw()