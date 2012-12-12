template = require 'views/templates/home'
PageView = require 'views/base/page_view'

module.exports = class HomePageView extends PageView
	template: template
	className: 'home-page'
	afterRender: ->
		super
		@canvas = @$('#slope').get(0)
		@context = @canvas.getContext('2d')
		@worker = new Worker 'javascripts/turnWorker.js'
		@work()

	draw: (data) ->
		for skier in data.skiers
			skier.color ?= "black"
			@context.strokeStyle = skier.color
			@context.beginPath()
			@context.moveTo skier.positions[0][0],skier.positions[0][1]
			for pair in skier.positions[0..]
				x = Math.round (pair[0]*30 + 5)
				y = Math.round (pair[1]*30 + 5)
				@context.lineTo x, y
				
			@context.closePath()
			@context.stroke()
  
	renderResults: (data) -> 
		for skier in data.skiers
			skier.color ?= "black"
			@$('#results').append($("<li></li>").html(skier.color + ' ' + skier.time))
		
	work: () =>
		@worker.onmessage = (event) =>
			if (event.data.type == 'final')
				@draw event.data
				console.log event.data
				@renderResults event.data
			else
				# clear the canvas
				@context.clearRect(0, 0, @canvas.width, @canvas.height)
				@context.beginPath()
				@context.moveTo event.data.best[0][0],event.data.best[0][1]
				for pair in event.data.best[0..]
					x = Math.round (pair[0]*30 + 5)
					y = Math.round (pair[1]*30 + 5)
					@context.lineTo x, y
					
				@context.closePath()
				@context.stroke()
				console.log event.data
			# alert "Computations finished in #{event.data[0]} seconds"
		@worker.postMessage()
