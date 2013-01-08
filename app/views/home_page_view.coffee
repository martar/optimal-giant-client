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

		@giantGates = [[17,5], [12,10], [7,15]] 
		#@giantGates = [[5,5],[0,10],[5,15], [4,20],[5,25], [2,30],[7,35], [3,44]]
		#@giantGates = [[5,13],[0,26],[5,39], [4,44],[5,49], [0,62], [5,75], [6,77], [3,80], [0,93]]
		# masks that point out which gates are the closed gates(1) and which are reguklar, open gates(0)
		@closedGates = [0,0,0]
		#@closedGates = [0,0,1,1,1,0,0,0]
		#@closedGates = [0,0,1,1,1,0,0,0,0,0]
		
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
		@drawGates()
		@context.beginPath()
		@context.moveTo trans(data.best[0][0]),trans(data.best[0][1])
		for pair in data.best[0..]
			x = trans(pair[0])
			y = trans(pair[1])
			@context.lineTo x, y
		@context.stroke()
			
	drawGates: () ->
		gates = zip(@giantGates,@closedGates)
		flagWidth = 0.75 # wigth of the flag between pols in meters
		gateWidth = 6 # between 4 and 8 m
		closerDistanceSkierPole = 0.2 # closest distance between the inner edge of skis and the outter pole of the turn gate
		# toggle flag for correct red/blue gates assignemt
		factor = -1
		for gate in gates[0..]
			pair = gate[0]
			isClosed = gate[1]
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
			if (!isClosed)
				@context.moveTo trans(pair[0]-factor*gateWidth), y
				@context.lineTo trans(pair[0]-factor*(gateWidth + flagWidth)), y
				@context.stroke()
				
			else
				# closed gate so put the gate in the line of the slope
				@context.moveTo x, trans(pair[1] + gateWidth - 2*flagWidth)
				@context.lineTo trans(pair[0]+factor* (closerDistanceSkierPole+flagWidth)),trans(pair[1] + gateWidth - 2*flagWidth)
				@context.stroke()
				# do not toggle the color
			factor = factor*(-1)
			@toggle = !@toggle
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
				#console.log event.data
				@renderResults event.data
			else if(event.data.type == 'intermediate')
				# clear the canvas
				@drawIntermediate event.data
				#console.log event.data
			else if (event.data.type == "stats")
				@processStatistics event.data
			else
				console.log event.data
			# alert "Computations finished in #{event.data[0]} seconds"
		@worker.postMessage({gates:zip(@giantGates,@closedGates)})
	
zip = () ->
  lengthArray = (arr.length for arr in arguments)
  length = Math.min(lengthArray...)
  for i in [0...length]
    arr[i] for arr in arguments	
