importScripts 'solver.js'
importScripts 'jshashtable.js'

solver = {}
solver.Skier = Skier

class State
	constructor: (v, @gates_dists) ->
		[@vx, @vy] = v
	
	equals: (obj) ->
		val = obj instanceof State and @roundVelocity(obj.vx) == @roundVelocity(@vx) and @roundVelocity(obj.vy) == @roundVelocity(@vy) and Utils.vectorDistance(obj.gates_dists[0],@gates_dists[0]) < 0.01
		return val
	
	hashCode: (obj) ->
		return @roundVelocity(@vx) + " " + @roundVelocity(@vy) + " " + @gates_dists[0][0] + " " + @gates_dists[0][1]
		
	roundVelocity: (coord) ->
		return Math.floor(coord/10)
	
class Environment
	constructor: (@dx,@dy,@gates,@startPoint=[0,0]) ->
		@sasa = 0
	
	getPossibleActions: (state) ->
	
		# the gate is reachable in this step - choose an action heading straight to gate
		if Math.abs(state.gates_dists[0][1] - @dy) < 0.01
			return [[new Action(state.gates_dists[0]),true]]
		
		# prepare possible actions
		actions = []
		for i in [-1..2] # -2 .. 2
			# change sign if we ride left
			actions.push([new Action([i*@dx, @dy]),false])
		return actions
	
	getNextGatesDistsAtStart: (n) ->
		dists = []
		st = @startPoint
		for gate in @gates[0..n-1]
			dists.push([gate.gate_x - st[0],gate.gate_y - st[1]])
		return dists
	
	getNextGatesDists: (n,cur_state,action, pos) ->
		dists = []
		[dx,dy] = action.getDests()
		i = 0
		if cur_state.gates_dists.length == 0
			return dists
		if cur_state.gates_dists[0][1] - dy == 0
			i = 1
		for dist in cur_state.gates_dists[i..]
			dists.push([dist[0]-dx,dist[1]-dy])
		#postMessage {d:dists}
		last = [0,0]
		if cur_state.gates_dists.length >= 1
			last = cur_state.gates_dists[cur_state.gates_dists.length-1]
		
		if dists.length < n
			dists.push(@getNextGate([pos[0] + last[0], pos[1] + last[1]]))
		#postMessage {d:dists}
		return dists
		
	getNextGate: (pos) ->
		#postMessage {pos:pos}
		i = 0 
		while i<@gates.length and pos[1] + 0.1 >= @gates[i].gate_y
			i+=1
		#postMessage {i:i, gate:@gates[i]}
		if i<@gates.length
			return [@gates[i].gate_x - pos[0], @gates[i].gate_y - pos[1]]
		return []

@Environment = Environment
		
class Action
	constructor: (dest) ->
		@dest = dest
	
	getDests: () ->
		@dest
		
	equals: (obj) ->
		return @dest[0] == obj.dest[0] && @dest[1] == obj.dest[1]
		
	hashCode: (obj) ->
		return @dest[0] + " " + @dest[1]
		
class Learning
	constructor: (@env, @alfa, @gamma, @endPoint, @startPoint = [0,0], @gates_nr = 1) ->
		@Q = new Hashtable()
		
	start: () ->
	
		# create and set up the skier
		skier = new solver.Skier(mi=0.05, m=60, C=0.6, A=0.2,  null, x0=[0,0], v0=[0,1])
		
		no_punish_factor = 1
		episode = 1
		MAX_EPISODES = 100
		while episode <= MAX_EPISODES
			skier.reset()
			gates_times = [0]
	
			#initial state
			current_state = new State(skier.getVelocities()[0],@env.getNextGatesDistsAtStart(@gates_nr,skier.getPosition()))
			
			# until we reach last gate
			while Utils.vectorDistance(skier.getPosition(),@endPoint) > 0.1
				
				possible_actions = @env.getPossibleActions(current_state)
				[action, isGate] = @chooseAction(possible_actions,current_state)
				
				[x,y] = skier.getPosition()
				[dx,dy] = action.getDests()
				
				skier.moveStraightToPoint(no_punish_factor,[x+dx,y+dy])
				
				new_state = new State(skier.getVelocities()[0],@env.getNextGatesDists(@gates_nr,current_state,action,[x,y]))
				
				time = 0
				if isGate
					gates_times.push(skier.result)
					time2 = gates_times[gates_times.length-1]
					time1 = gates_times[gates_times.length-1-@gates_nr]
					time = time2-time1
				
				reward = @getReward(time,isGate)
				
				@updateQ(current_state, action, reward, new_state)
				current_state = new_state
			#postMessage {type:"intermediate", best:skier.getPositions()}
			episode += 1
		#for en in @Q.entries()
		#	postMessage {state_x:en[0].gates_dists[0][0],state_y:en[0].gates_dists[0][1],actions:en[1].keys()[0].dest[0], val:en[1].values()[0]}
		
		pos = @findBest()
		postMessage {type:"intermediate", best:pos}
	
	findBest: () ->
		cur_pos = [0,0]
		pos = [cur_pos]
		state = new State([0,1],@env.getNextGatesDistsAtStart(@gates_nr,cur_pos))
		
		while Utils.vectorDistance(cur_pos,@endPoint) > 0.1
			max = 0
			action = null
			if not @Q.containsKey(state)
				st = []
				st.push k if k.gates_dists[0][1] == z for k in @Q.keys()
				postMessage {s:state, sa:st}
			
			for _,[act,val] of @Q.get(state).entries()
				if val >= max
					max = val
					action = act
			if not action
				postMessage {s:"action is null"}
				return pos
			else
				postMessage {action_x:action.dest[0], v:max}
			cur_pos = [cur_pos[0] + action.dest[0], cur_pos[1] + action.dest[1]]
			pos.push(cur_pos)
			[gsx,gsy] = state.gates_dists[0]
			state = new State([0,0],[[gsx-action.dest[0],gsy-action.dest[1]]])
			
		return pos
		
	chooseAction: (actions,state) ->
		#postMessage {s:state,a:actions}
		sum = 0
		probs = []
		for action in actions
			a = action[0]
			action_val = 0
			if @Q.containsKey(state)
				if @Q.get(state).containsKey(a)
					action_val = @Q.get(state).get(a)
					#if action_val>1
					#	postMessage {v:action_val}
			# if there is no action yet or the value is < MIN_VAL
			MIN_VAL = 0.2
			if action_val < MIN_VAL
				action_val = MIN_VAL
			probs.push(action_val)
			sum += action_val
		
		#i = Math.floor(Math.random()*actions.length)
		random_val = Math.random()*sum
		i = 0
		p = probs[0]
		while i+1 < actions.length
			if random_val < p
				#if sum/probs.length != 1
				#	postMessage {probs:probs}
				#	postMessage {r:random_val, i:i}
				return [actions[i][0],actions[i][1]]
			p += probs[i+1]
			i += 1
		#if sum/probs.length != 1
		#	postMessage {probs:probs}
		#	postMessage {r:random_val, i:i}
		return [actions[i][0],actions[i][1]]
		
	updateQ: (state, action, reward, future_state) ->
		#Q[s,a] ‹- Q[s,a] + alfa*(r + gamma * max((a') Q[s',a']) - Q[s,a])
		max = @_getMax(future_state)
		if not @Q.containsKey(state)
			@Q.put(state,new Hashtable())
		
		if not @Q.get(state).containsKey(action)
			@Q.get(state).put(action,0)
			
		old_val = @Q.get(state).get(action)
		new_val = old_val + @alfa*(reward + @gamma*max - old_val)
		
		@Q.get(state).put(action,new_val)
		
	getReward: (t, isGate) ->
		upper_bound_time = 10
		if not isGate
			return 0
		return upper_bound_time-t
		
	_getMax: (state) ->
		max = 0
		if @Q.containsKey(state)
			for _,[act,val] of @Q.get(state).entries()
				if(val > max)
					max = val
		return max
		
@Learning = Learning