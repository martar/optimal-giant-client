template = require 'views/templates/home'
PageView = require 'views/base/page_view'

###
This is stupid. But without some set of initial data, the chart doesn't update well later on
###
dataGen = () ->
	data = []
	time = (new Date()).getTime()
	for i in [-19..0] by 1
		data.push({
			x: time + i * 1000,
			y: 11
		})
	data
	
fu = () ->
	chart = new Highcharts.Chart({
		chart: {
			renderTo: 'stats_container',
			type: 'spline',
			marginRight: 10

		},
		title: {
			text: 'Live skier data'
		},
		xAxis: {
			type: 'datetime',
			tickPixelInterval: 150
		},
		yAxis: {
			title: {
				text: 'Value'
			},
			plotLines: [{
				value: 0,
				width: 1,
				color: '#808080'
			},
			{
				value: 0,
				width: 1,
				color: 'red'
			},
			{
				value: 0,
				width: 1,
				color: 'yellow'
			}]

		},

		legend: {
			enabled: true
		},

		exporting: {
			enabled: false
		},
		
		series: [
			{name: 'AverageFitness',data: dataGen()},
			{name:'Best Fitness', data: dataGen()},
			{name:'Worst Fitness', data: dataGen()},
			]
	})
	chart


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

		@chart = fu()
		Highcharts.setOptions({
            global: { useUTC: false}
		})
		
		#@giantGates = [[5,5],[0,10],[5,15], [4,20],[5,25], [2,30],[7,35], [3,44]]
		#@giantGates = [[5,5],[0,10],[5,15], [4,20],[7,25], [0, 30]]
		
		#@giantGates = [[5,13],[0,26],[5,39], [4,44],[5,49], [0,62]]
		@giantGates = [[5,13],[0,26],[5,39], [4,44],[11,57], [0,70]]
		# masks that point out which gates are the closed gates(1) and which are reguklar, open gates(0)
		#@closedGates = [0,0,1,1,0,0]
		#@closedGates = [0,0,1,1,1,0,0,0,0,0]
		@closedGates = [0,0,1,1,0,0]
		#@giantGates = [[5,13],[0,26],[5,39], [4,44],[5,49], [0,62], [5,75], [6,77], [3,80], [0,93]]
		# masks that point out which gates are the closed gates(1) and which are reguklar, open gates(0)
		#@closedGates = [0,0,1,1,1,0,0,0]
		#@closedGates = [0,0,1,1,1,0,0,0,0,0]
		
		
		@work()

	transX = (coord) -> Math.round (coord*10+100)
	transY = (coord) -> Math.round (coord*10+100)	
	
	draw: (data) ->
		for skier in data.skiers
			skier.color ?= "black"
			@context.strokeStyle = skier.color
			@context.beginPath()
			@context.moveTo transX(skier.positions[0][0]),transY(skier.positions[0][1])
			for pair in skier.positions[0..]
				x = transX(pair[0])
				y = transY(pair[1])
				@context.lineTo x, y
			@context.stroke()
  
	drawIntermediate: (data) ->
		@context.clearRect(0, 0, @canvas.width, @canvas.height)
		@drawGates()
		@context.beginPath()
		@context.moveTo transX(data.best[0][0]),transY(data.best[0][1])
		for pair in data.best[0..]
			x = transX(pair[0])
			y = transY(pair[1])
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
			x = transX(pair[0]+factor* closerDistanceSkierPole)
			y = transY(pair[1])
			@context.moveTo x,y
			@context.lineTo transX(pair[0]+factor*flagWidth), y
			if (!isClosed)
				@context.moveTo transX(pair[0]-factor*gateWidth), y
				@context.lineTo transX(pair[0]-factor*(gateWidth + flagWidth)), y
				@context.stroke()
				
			else
				# closed gate so put the gate in the line of the slope
				@context.moveTo x, transX(pair[1] + gateWidth - 2*flagWidth)
				@context.lineTo transX(pair[0]+factor* (closerDistanceSkierPole+flagWidth)),transY(pair[1] + gateWidth - 2*flagWidth)
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
			@chart.series[0].addPoint([(new Date()).getTime(), data.value], false, true)
		else if (data.plugin == "BestFitness")
			@chart.series[1].addPoint([(new Date()).getTime(), data.value], false, true)
		else if (data.plugin == "WorstFitness")
			@chart.series[2].addPoint([(new Date()).getTime(), data.value], true, true)
	
	work: () =>
		i=0
		@worker.onmessage = (event) =>
			i += 1
			if (event.data.type == 'final')
				@draw event.data
				# console.log event.data
				# @renderResults event.data
			else if(event.data.type == 'intermediate' and i % 10 == 0)
				# clear the canvas
				@drawIntermediate event.data
				# console.log event.data
			else if (event.data.type == "stats" and i % 10 == 0)
				@processStatistics event.data
			else
				# console.log event.data
			# alert "Computations finished in #{event.data[0]} seconds"
		@worker.postMessage({gates:zip(@giantGates,@closedGates)})
	
zip = () ->
  lengthArray = (arr.length for arr in arguments)
  length = Math.min(lengthArray...)
  for i in [0...length]
    arr[i] for arr in arguments	
