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
		@avgFitness = [[]]
		@bestFitness = [[]]
		@worstFitness = [[]]
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
  
	drawIntermediate: (data) ->
		@context.clearRect(0, 0, @canvas.width, @canvas.height)
		@context.beginPath()
		@context.moveTo data.best[0][0],data.best[0][1]
		for pair in data.best[0..]
			x = Math.round (pair[0]*30 + 5)
			y = Math.round (pair[1]*30 + 5)
			@context.lineTo x, y
			
		@context.closePath()
		@context.stroke()
		
	renderResults: (data) -> 
		for skier in data.skiers
			skier.color ?= "black"
			@$('#results').append($("<li></li>").html(skier.color + ' ' + skier.time))
	
	processStatistics: (data) =>
		if (data.plugin == "AverageFitness")
			@avgFitness.push( [@avgFitness.length, data.value])
		else if (data.plugin == "BestFitness")
			@bestFitness.push( [@bestFitness.length, data.value])
		else if (data.plugin == "WorstFitness")
			@worstFitness.push( [@worstFitness.length, data.value])
		plot1 = $.jqplot('stats_plots',  [@avgFitness, @bestFitness, @worstFitness], {
			title:"Live alg stats: best, avg and worst fitness in population"
		})
		plot1.redraw()
	
	work: () =>
		@worker.onmessage = (event) =>
			if (event.data.type == 'final')
				@draw event.data
				console.log event.data
				@renderResults event.data
			else if(event.data.type == 'intermediate')
				# clear the canvas
				@drawIntermediate event.data
				console.log event.data
			else if (event.data.type == "stats")
				@processStatistics event.data
			else
				console.log event.data
			# alert "Computations finished in #{event.data[0]} seconds"
		@worker.postMessage({})
		
