// Generated by CoffeeScript 1.3.3
(function() {

  importScripts('optimizePoints.js');

  importScripts('solver.js');

  self.onmessage = function(ev) {
    var bests, crossNr, duration, endPoint, first, mutateProb, pop, populationCount, second, skier1, skier2, start, vLen;
    start = Date.now();
    populationCount = 10;
    vLen = 0.1;
    endPoint = [10, 10];
    pop = new PointTurns(2, populationCount, vLen, endPoint);
    crossNr = 5;
    mutateProb = 5;
    bests = new Optimization(pop, crossNr, mutateProb).compute();
    'skier3 = new Skier(@mi=0, @m=60, @C=0, @A=0, @solver=new OptimalGiant.Solver, @x0=[0,0], @v0=[0,1])\nn = 0\nsteep = 0.01\nt0 = 0\nkappa = skier2.computeKappa(endPoint)\nwhile !skier2.isNear(endPoint)\n	t1 = t0+steep\n	skier2.move(t0, t1, kappa, 1)\n	t0 = t1\nt0 = t1-steep\nskier2.getPositions().pop()';

    first = pop.idvs[0];
    skier1 = first.skier;
    second = pop.idvs[1];
    skier2 = second.skier;
    duration = Date.now() - start;
    return postMessage({
      v_alpha: first.value,
      time: first.fitness,
      skiers: [
        {
          positions: skier1.getPositions(),
          color: "red",
          velocities: skier1.getVelocities(),
          time: first.fitness
        }, {
          positions: skier2.getPositions(),
          color: "blue",
          velocities: skier2.getVelocities(),
          time: second.fitness
        }
      ]
    });
  };

}).call(this);
