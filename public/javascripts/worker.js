// Generated by CoffeeScript 1.3.3
(function() {
  var vectorDistance;

  importScripts('solver.js');

  vectorDistance = function(vector) {
    return Math.sqrt(Math.pow(vector[0], 2) + Math.pow(vector[1], 2));
  };

  self.onmessage = function(ev) {
    var accuracy, endPoint, kappa, lol, pos, skier, skier2, skier3, skiers, startPoint, steep, steepPositions, vcoord, vstart, x, _i, _len;
    vstart = [0, 0.001];
    startPoint = [0, 0];
    steep = 0.001;
    endPoint = [10, 10];
    accuracy = 0.001;
    skier = new Skier(this.mi = 0.00, this.m = 60, this.C = 0.0, this.A = 0.2, this.solver = new OptimalGiant.Solver, this.x0 = startPoint, this.v0 = vstart);
    skier.color = "red";
    kappa = skier.computeKappa(endPoint);
    skier.moveToPoint(steep, kappa, endPoint, accuracy);
    steepPositions = ((function() {
      var _i, _len, _ref, _results, _step;
      _ref = skier.getPositions();
      _results = [];
      for (_i = 0, _len = _ref.length, _step = 100; _i < _len; _i += _step) {
        x = _ref[_i];
        _results.push(x);
      }
      return _results;
    })()).reverse();
    skier2 = new Skier(this.mi = 0.00, this.m = 60, this.C = 0.0, this.A = 0.2, this.solver = new OptimalGiant.Solver, this.x0 = startPoint, this.v0 = vstart);
    for (_i = 0, _len = steepPositions.length; _i < _len; _i++) {
      pos = steepPositions[_i];
      skier2.moveStraightToPoint(steep, pos, accuracy);
    }
    vcoord = vectorDistance(vstart) / 1.42;
    skier3 = new Skier(this.mi = 0.00, this.m = 60, this.C = 0.0, this.A = 0.2, this.solver = new OptimalGiant.Solver, this.x0 = startPoint, this.v0 = [vcoord, vcoord]);
    kappa = 0.000001;
    skier3.moveToPoint(steep, kappa, endPoint, accuracy);
    skier3.color = "blue";
    skiers = [];
    skiers.push(skier);
    skiers.push(skier2);
    skiers.push(skier3);
    lol = (function() {
      var _j, _len1, _results;
      _results = [];
      for (_j = 0, _len1 = skiers.length; _j < _len1; _j++) {
        skier = skiers[_j];
        _results.push({
          time: skier.result,
          positions: skier.getPositions(),
          color: skier.color,
          diff: skier.positions[0]
        });
      }
      return _results;
    })();
    return postMessage({
      skiers: lol
    });
  };

}).call(this);
