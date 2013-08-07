Model = require 'models/base/model'
# SERVER_URI = 'http://giant-server.herokuapp.com:80/'
SERVER_URI = process.env.SERVER_URI ? 'http://localhost:5000/'


module.exports = class Problem extends Model
	defaults:
		title: ''
		completed: no

	initialize: ->
		super
		@set 'created', Date.now() if @isNew()
	
	# load the problem instance from the server
	load: (onSuccess) =>
		$.ajax
			type: 'GET'
			url: SERVER_URI + "slalom"
			dataType: "json"
			success: (data) => 
				@set data
				onSuccess data
			error: (evt) ->
				console.dir "[Client][REST]  Error getting the prolem instance: #{evt}"
	# get the best result for this problem
	getBestResult: (onSuccess) =>
		$.ajax
			type: 'GET'
			url: SERVER_URI + "result/" + @get '_id'
			dataType: "json"
			success: (data) => 
				console.dir "[Client][REST]  Success getting the best result"
				onSuccess(data.bestTimeInDb)
			error: (evt) ->
				console.dir "[Client][REST]  Error getting the best result:"
				console.dir evt
				
	postResult: (result, onSuccess) =>
		$.ajax
			type: 'POST'
			url: SERVER_URI + "slalom"
			data: result
			dataType: "json"
			ContentType: "application/json; charset=UTF-8"
			success: (data) -> 
				console.dir data
				onSuccess data
			error: (evt) ->
				console.dir "[Client][REST] Error posting the result: #{evt}"