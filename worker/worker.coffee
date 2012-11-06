importScripts 'solver.js'                                                             
self.onmessage = (ev) ->
    start = Date.now()
    skier = new OptimalGiant.Skier(@mi=0.05, @m=60, @C=0.6, @A=0.2, @solver=new OptimalGiant.Solver, @x0=[0,0], @v0=[0,0])
    skier2 = new OptimalGiant.Skier(@mi=0.05, @m=60, @C=0.6, @A=0.2, @solver=new OptimalGiant.Solver, @x0=[0,0], @v0=[0,10])
    n = 0
    steep = 0.01
    t0 = 0
    while n < 5000
      t1 = t0+steep
      skier.move(t0, t1, 0.05, 1)
      skier2.move(t0, t1, 0.05, 1)
      t0 = t1
      n += 1 
    duration = Date.now() - start
    postMessage {duration: duration, skiers: [{positions: skier.getPositions(), color: "red"},{positions: skier2.getPositions(), color: "blue"}]}
