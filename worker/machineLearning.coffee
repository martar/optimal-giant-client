importScripts 'solver.js'
importScripts 'jshashtable-2.1.js'

solver = {}
solver.Skier = Skier

#wywalic endpoint!!!!

class State
	constructor: (v, @gates_dists) ->
		[@vx, @vy] = v
	
	equals: (obj) ->
		val = obj instanceof State and obj.vx == @vx and obj.vy == @vy and Utils.vectorDistance(obj.gates_dists[0],@gates_dists[0]) < 0.01
		postMessage {comp:"compare!", val:val}
		if val
			postMessage {this:this, obj:obj}
		return val
		
class Environment
	constructor: (@dx,@dy,@gates,@startPoint=[0,0]) ->
		@sasa = 0
	
	getPossibleActions: (state) ->
		if Math.abs(state.gates_dists[0][1] - @dy) < 0.01
			return [new Action(state.gates_dists[0])]
			
		actions = []
		for i in [-1..3]
			#change sign if we ride left
			if i!=0
				actions.push(new Action([i*@dx, @dy]))
		return actions
		
	getNextGatesDistsAtStart: (n) ->
		dists = []
		st = @startPoint
		for gate in @gates[0..n-1]
			dists.push([gate.gate_x - st[0],gate.gate_y - st[1]])
		return dists
	
	getNextGatesDists: (n,cur_state,action, pos) ->
		dists = []
		postMessage {n:n,c:cur_state,a:action, p:pos}
		[dx,dy] = action.getDeltas()
		i = 0
		if cur_state.gates_dists.length == 0
			return dists
		if cur_state.gates_dists[0][1] - dy == 0
			i = 1
		for dist in cur_state.gates_dists[i..]
			dists.push([dist[0]-dx,dist[1]-dy])
		postMessage {d:dists}
		last = [0,0]
		if cur_state.gates_dists.length >= 1
			last = cur_state.gates_dists[cur_state.gates_dists.length-1]
		
		if dists.length < n
			dists.push(@getNextGate([pos[0] + last[0], pos[1] + last[1]]))
		postMessage {d:dists}
		return dists
		
	getNextGate: (pos) ->
		postMessage {pos:pos}
		i = 0 
		while i<@gates.length and pos[1] + 0.1 >= @gates[i].gate_y
			i+=1
		postMessage {i:i, gate:@gates[i]}
		if i<@gates.length
			return [@gates[i].gate_x - pos[0], @gates[i].gate_y - pos[1]]
		return []

@Environment = Environment
		
class Action
	constructor: (dest) ->
		@dest = dest
	
	getDeltas: () ->
		@dest
		
class Learning
	constructor: (@env, @alfa, @gamma, @endPoint, @startPoint = [0,0], @gates_nr = 1) ->
		@Q = new Hashtable()
		
	# !!! add evaluating reward basing on time!!!!	
	
	start: () ->
		#create skier
		skier = new solver.Skier()
		postMessage {vel:skier.getVelocities(), pos:skier.getPositions()}
		a = 1
		while a < 3
			skier.reset()
			postMessage {a:a}
			#initial state
			current_state = new State(skier.getVelocities()[0],@env.getNextGatesDistsAtStart(@gates_nr,skier.getPosition()))
			postMessage {pos: skier.getPosition(), end:@endPoint, cur: current_state}
			while Utils.vectorDistance(skier.getPosition(),@endPoint) > 0.1
				postMessage {cur: current_state}
				possible_actions = @env.getPossibleActions(current_state)
				postMessage {ac:possible_actions}
				[action, isGate] = @chooseAction(possible_actions)
				postMessage {action: action}
				[x,y] = skier.getPosition()
				[dx,dy] = action.getDeltas()
				postMessage {a:"bef", x:x, dx:dx, y:y, dy:dy}
				postMessage {type:"intermediate", best:skier.getPositions()}
				skier.moveStraightToPoint(1,[x+dx,y+dy])
				postMessage {a:"after"}
				new_state = new State(skier.getVelocities()[0],@env.getNextGatesDists(@gates_nr,current_state,action,[x,y]))
				time = 0
				reward = @getReward(time,isGate)
				#postMessage {rew: reward, new_s: new_state}
				@updateQ(current_state, action, reward, new_state)
				current_state = new_state
			postMessage {type:"intermediate", best:skier.getPositions()}
			postMessage {pos_y: skier.getPosition()[1], end:@endPoint[1]}
			a += 1
			for en in @Q.entries()
				postMessage {state:en[0],actions:en[1].keys(), val:en[1].values()}
			
	chooseAction: (actions) ->
		i = Math.floor(Math.random()*actions.length)
		postMessage {i:i}
		return [actions[i],actions.length==1]
		
	updateQ: (state, action, reward, future_state) ->
		#Q[s,a] ‹Q[s,a] + a(r+ y * max((a') Q[s',a']) - Q[s,a])
		postMessage {s:state, a:action, r:reward,fs: future_state}
		max = 0
		if future_state in @Q
			for act,val of @Q.get(future_state)
				if(val > max)
					max = val
		if state not in @Q
			#postMessage {a: "add state"}
			@Q.put(state,new Hashtable())
		if action not in @Q.get(state)
			#postMessage {a: "init action"}
			@Q.get(state).put(action,0)
		else
			postMessage {s:"already in"}
		postMessage {max:max}
		old_val = @Q.get(state).get(action)
		postMessage {ov: old_val}
		new_val = old_val + @alfa*(reward + @gamma*max - old_val)
		postMessage {nv: new_val}
		@Q.get(state).put(action,new_val)
		# postMessage {Q:@Q}
		
	getReward: (t, isGate) ->
		if not isGate
			return 0
		return 10-t
		
@Learning = Learning