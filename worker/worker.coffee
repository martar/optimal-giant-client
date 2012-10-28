importScripts 'solver.js'                                                             
self.onmessage = (ev) ->
    start = Date.now()
    result = OptimalGiant.solver(0,1,ev.data.v0,ev.data.kappa)    
    duration = Date.now() - start
    postMessage [duration, result]
