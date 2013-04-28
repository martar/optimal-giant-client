Model = require 'models/base/model'
SERVER_URL = 'http://localhost:8080/'

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
			url: SERVER_URL + "slalom"
			dataType: "json"
			success: (data) => 
				@set data
				onSuccess data
			error: (evt) ->
				# console.log "[Client][REST]  Error getting the prolem instance: #{evt}"
				
	postResult: (result, onSuccess) =>
		$.ajax
			type: 'POST'
			url: SERVER_URL + "slalom"
			data: result
			dataType: "json"
			ContentType: "application/json; charset=UTF-8"
			success: (data) -> 
				console.dir data
				onSuccess data
			error: (evt) ->
				# console.log "[Client][REST] Error posting the result: #{evt}"