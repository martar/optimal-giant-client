template = require 'views/templates/home'
PageView = require 'views/base/page_view'

module.exports = class HomePageView extends PageView
	template: template
	className: 'home-page'
	afterRender: ->
		super
		@toggle = true
		@canvas = @$('#slope').get(0)
		@context = @canvas.getContext('2d')
		@worker = new Worker 'javascripts/turnWorker.js'
		@avgFitness = [[]]
		@bestFitness = [[]]
		@worstFitness = [[]]
		@giantGates = [[5,5],[0,10],[5,15], [4,20], [7,25], [3,27]]
		@work()


	trans = (coord) -> Math.round (coord*30 + 5)
	
	draw: (data) ->
		for skier in data.skiers
			skier.color ?= "black"
			@context.strokeStyle = skier.color
			@context.beginPath()
			@context.moveTo trans(skier.positions[0][0]),trans(skier.positions[0][1])
			for pair in skier.positions[0..]
				x = trans(pair[0])
				y = trans(pair[1])
				@context.lineTo x, y
			@context.stroke()
  
	drawIntermediate: (data) ->
		@context.clearRect(0, 0, @canvas.width, @canvas.height)
		@drawGates(@giantGates)
		@context.beginPath()
		@context.moveTo trans(data.best[0][0]),trans(data.best[0][1])
		for pair in data.best[0..]
			x = trans(pair[0])
			y = trans(pair[1])
			@context.lineTo x, y
		@context.stroke()
			
	drawGates: (gates) ->
		flagWidth = 0.75 # wigth of the flag between pols in meters
		gateWidth = 6 # between 4 and 8 m
		closerDistanceSkierPole = 0.2 # closest distance between the inner edge of skis and the outter pole of the turn gate
		# toggle flag for correct red/blue gates assignemt
		factor = -1
		for pair in gates[0..]
			@context.beginPath()
			@context.lineWidth = 5
			if (@toggle)
				@context.strokeStyle = 'blue'
			else
				@context.strokeStyle = 'red'
			x = trans(pair[0]+factor* closerDistanceSkierPole)
			y = trans(pair[1])
			@context.moveTo x,y
			@context.lineTo trans(pair[0]+factor*flagWidth), y
			@context.moveTo trans(pair[0]-factor*gateWidth), y
			@context.lineTo trans(pair[0]-factor*(gateWidth + flagWidth)), y
			@context.stroke()
			@toggle = !@toggle
			factor = factor*(-1)
		@context.lineWidth = 1
		@context.strokeStyle = 'black'
		
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
			else if (event.data.type == 'intermediate')
				# clear the canvas
				@drawIntermediate event.data
				console.log event.data
			else if (event.data.type == "stats")
				@processStatistics event.data
			else
				console.log event.data
			# alert "Computations finished in #{event.data[0]} seconds"
		@worker.postMessage({gates:@giantGates})
		
