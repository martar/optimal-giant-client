template = require 'views/templates/home'
PageView = require 'views/base/page_view'

module.exports = class HomePageView extends PageView
  template: template
  className: 'home-page'
  afterRender: ->
    super
    @context = @$('#slope').get(0).getContext('2d')
    @worker = new Worker 'javascripts/worker.js'
    @work()
	
  draw: (data) =>
    for skier in data.skiers
      skier.color ?= "black"
      @context.strokeStyle = skier.color
      for pair in skier.positions
        x = Math.round (pair[0]*10)
        y = Math.round (pair[1]*10)
        @context.beginPath()
        @context.moveTo x,y
        @context.lineTo x+1, y+1
        @context.stroke()
  
  work: () =>
    @worker.onmessage = (event) =>
      @draw event.data
      # alert "Computations finished in #{event.data[0]} seconds"
    @worker.postMessage()
