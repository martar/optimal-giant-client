###
module for displaying real time statistics from the optimization algorithm
###

class AverageFitnessPlugin
	###
	Callback to called every time the new data arrives
	###
	feed: (fitnessListInPopulation) ->
		sum = 0
		for ind in fitnessListInPopulation
			sum += ind.skier.result
		postMessage({type: "stats", plugin: "AverageFitness", value: sum/fitnessListInPopulation.length})
		
class BestFitnessInPopulationPlugin
	###
	Callback to called every time the new data arrives
	###
	feed: (fitnessListInPopulation) ->
		min = null
		for ind in fitnessListInPopulation
			if min == null or ind.skier.result < min 
				min = ind.skier.result
		postMessage({type: "stats", plugin: "BestFitness", value: min})

class WorstFitnessInPopulationPlugin
	###
	Callback to called every time the new data arrives
	###
	feed: (fitnessListInPopulation) ->
		min = null
		for ind in fitnessListInPopulation
			if min == null or ind.skier.result > min 
				min = ind.skier.result
		postMessage({type: "stats", plugin: "WorstFitness", value: min})
		
class Stats
	
	###
	configuration. Which stats plugins should be anabled
	###
	constructor: () ->
		@plugins = [new BestFitnessInPopulationPlugin(), new AverageFitnessPlugin(), new WorstFitnessInPopulationPlugin()]
		
	###
	Callback to called every time the new data arrives
	###
	feed: (fitnessListInPopulation) ->
		for plugin in @plugins
			plugin.feed(fitnessListInPopulation)

@Stats = Stats