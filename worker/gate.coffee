
class Point
	constructor: (@x,@y,@dev=1) ->

	createCopy: () ->
		new Point(@x,@y,@dev)
	
	correct: () ->
		true

class Gate extends Point
	constructor: (gate,@left,@dev=1,@gate_x=0,@gate_y=0) ->
		super gate[0][0],gate[0][1]
		if @gate_x == 0 and @gate_y == 0
			@gate_x = @x
			@gate_y = @y
		@closed = gate[1]
	
	createCopy: () ->
		new Gate([[@x,@y],@closed],@left,@dev,@gate_x,@gate_y)

	correct: () ->
		false

@Gate = Gate
@Point = Point