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

general_chart = (avg, best, worst) ->
	general = new Highcharts.Chart({
		chart: {
			renderTo: 'general_stats_container',
			type: 'spline',
			marginRight: 10

		},
		title: {
			text: 'Overall fitness of the population'
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
			{name: 'AverageFitness',data: avg},
			{name:'Best Fitness', data: best},
			{name:'Worst Fitness', data: worst},
			]
	})
fu = () ->
	chart = new Highcharts.Chart({
		chart: {
			renderTo: 'stats_container',
			type: 'spline',
			marginRight: 10

		},
		title: {
			text: 'Fitness of the population'
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
	
	# i supose it is not a proper way of passing model throug controller to view.. but it is a only way it workeds
	constructor : (@problem) ->
		super
		
	onSuccess: (result) =>
		#@giantGates =  [[3,10],[-5,30],[4,50],[-4,65],[-16,80],[-6,100],[-13,120],[-10,135]]
		#@closedGates =  [0,0,0,0,0,0,0,0]
		@problemId = @problem.attributes._id
		@giantGates = @problem.attributes.giantGates
		# closedGates and hasLeftSidePollGatces are masks that point out which where is the closing poll of the gate and whether it is a closed or open gate (eneeded for visualization)
		@closedGates = @problem.attributes.closedGates
		@hasLeftSidePollGates = @problem.attributes.hasLeftSidePollGates
		@work()
		
	afterRender: =>
		super
		console.dir @problem
		@toggle = true
		@canvas = @$('#slope').get(0)
		@getProblemButton = @$('#get-problem-button')
		@dancers = @$('#dancers')
		@success =  @$('#success')
		@nsolved = @$('#nsolved')
		@musicoff = @$('#musicoff')
		@musicoff.click () =>
			@$('#game').remove()
		@numberOfSolved = 0
		@computationContainer = @$('#computation')
		@getProblemButton.click () =>
			@problem.load @onSuccess
			@success.hide()
		@context = @canvas.getContext('2d')
		@worker = new Worker 'javascripts/turnWorker.js'
		@avgFitness = [[]]
		@bestFitness = [[]]
		@worstFitness = [[]]

		@chart = fu()
		Highcharts.setOptions({
            global: { useUTC: false}
		})
		
		

	transX = (coord) -> Math.round (coord*10+175)
	transY = (coord) -> Math.round (coord*10+100)	
	
	draw: (data) =>
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
  
	drawIntermediate: (data) =>
		@context.clearRect(0, 0, @canvas.width, @canvas.height)
		@drawGates()
		@context.beginPath()
		@context.moveTo transX(data.best[0][0]),transY(data.best[0][1])
		for pair in data.best[0..]
			x = transX(pair[0])
			y = transY(pair[1])
			@context.lineTo x, y
		@context.stroke()
			
	drawGates: () =>
		gates = zip(@giantGates,@closedGates, @hasLeftSidePollGates)
		flagWidth = 0.75 # wigth of the flag between pols in meters
		gateWidth = 10 # between 4 and 8 m
		closerDistanceSkierPole = 0.2 # closest distance between the inner edge of skis and the outter pole of the turn gate
		# toggle flag for correct red/blue gates assignemt
		for gate, i in gates[0..]
			pair = gate[0]
			isClosed = gate[1]
			isLeft = gate[2]
			if isLeft
			  factor = 1
			else 
			  factor = -1
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
				@context.moveTo x, transY(pair[1] + gateWidth - 2*flagWidth)
				@context.lineTo transX(pair[0]+factor* (closerDistanceSkierPole+flagWidth)), transY(pair[1] + gateWidth - 2*flagWidth)
				@context.stroke()
				# do not toggle the color
			@toggle = !@toggle
		@context.lineWidth = 1
		@context.strokeStyle = 'black'
		
	renderResults: (data) => 
		general_chart(@avgFitness, @bestFitness, @worstFitness)
		#for skier in data.skiers
		#	skier.color ?= "black"
		#	@$('#results').append($("<li></li>").html(skier.color + ' ' + skier.time))
	
	processStatistics: (data) =>
		if (data.plugin == "AverageFitness")
			@avgFitness.push(data.value)
			@chart.series[0].addPoint([(new Date()).getTime(), data.value], false, true)
		else if (data.plugin == "BestFitness")
			@bestFitness.push(data.value)
			@chart.series[1].addPoint([(new Date()).getTime(), data.value], false, true)
		else if (data.plugin == "WorstFitness")
			@worstFitness.push(data.value)
			@chart.series[2].addPoint([(new Date()).getTime(), data.value], true, true)
	
	work: () =>
		i=0
		@getProblemButton.hide()
		@dancers.show()
		@computationContainer.show()
		console.log "LOOOOOL"
		@worker.onmessage = (event) =>
			i += 1
			if (event.data.type == 'final')
				@draw event.data
				# console.log event.data
				@renderResults event.data
				event.data.problem_id = @problemId
				event.data.type = "GIANT_RESULT"
				@dancers.fadeOut()
				@success.show()	
				@problem.postResult event.data, () =>
					@problem.load @onSuccess
					@success.hide()		
					@numberOfSolved += 1
					@nsolved.html(@numberOfSolved)
			if(event.data.type == 'intermediate')
				# clear the canvas
				@drawIntermediate event.data
				# console.log event.data
			if (event.data.type == "stats")
				@processStatistics event.data
			else
				console.log event.data
			# alert "Computations finished in #{event.data[0]} seconds"
		@worker.postMessage({gates:zip(@giantGates,@closedGates), hasLeftSidePollGates: @hasLeftSidePollGates})
	
zip = () ->
  lengthArray = (arr.length for arr in arguments)
  length = Math.min(lengthArray...)
  for i in [0...length]
    arr[i] for arr in arguments	
