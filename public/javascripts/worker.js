// Generated by CoffeeScript 1.3.3
(function() {
  var testRun,
    _this = this;

  importScripts('solver.js');

  testRun = function(points) {
    var accuracy, point, skier, v0, x0, _i, _len;
    accuracy = 0.01;
    skier = new Skier(null, null, null, null, null, x0 = [0, 0], v0 = [0.001, 0]);
    for (_i = 0, _len = points.length; _i < _len; _i++) {
      point = points[_i];
      skier.moveStraightToPoint(point, accuracy);
    }
    return skier;
  };

  self.onmessage = function(ev) {
    var lol, p1, p2, skier, skiers;
    p1 = [[2.5, 2.5], [5, 5], [2.5, 7.5], [0, 10], [2.5, 12.5], [5, 15]];
    p2 = [[4, 2.5], [5, 5], [4, 7.5], [0, 10], [1, 12.5], [5, 15]];
    skiers = [testRun(p1), testRun(p2)];
    lol = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = skiers.length; _i < _len; _i++) {
        skier = skiers[_i];
        _results.push({
          time: skier.result,
          positions: skier.getPositions(),
          color: skier.color
        });
      }
      return _results;
    })();
    return postMessage({
      type: 'final',
      skiers: lol
    });
  };

}).call(this);
