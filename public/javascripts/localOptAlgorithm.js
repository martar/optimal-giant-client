// Generated by CoffeeScript 1.3.3
(function() {
  var LocalOptimization, solver,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  importScripts('./solver.js');

  importScripts('./statistics.js');

  solver = {};

  solver.Skier = Skier;

  LocalOptimization = (function() {
    var computeRedundantEdgeChangePunish,
      _this = this;

    function LocalOptimization(init_skier, gates, val, startPoint) {
      var gate;
      this.init_skier = init_skier;
      this.gates = gates;
      this.val = val;
      this.startPoint = startPoint != null ? startPoint : [0, 0];
      this.computePunishment = __bind(this.computePunishment, this);

      this.current_result = this.init_skier.positions.reverse().slice(1);
      this.gatesys = (function() {
        var _i, _len, _ref, _results;
        _ref = this.gates;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          gate = _ref[_i];
          _results.push(gate[0][1]);
        }
        return _results;
      }).call(this);
      postMessage({
        result: this.current_result,
        ys: this.gates
      });
    }

    LocalOptimization.prototype.compute = function() {
      var acceleration, before, best, bestScore, candidate, curFitness, epsilon, i, j, stepSize, temp, _i, _j, _ref, _ref1;
      postMessage({
        start: "start"
      });
      stepSize = (function() {
        var _i, _ref, _results;
        _results = [];
        for (i = _i = 1, _ref = this.current_result.length; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
          _results.push(0.5);
        }
        return _results;
      }).call(this);
      acceleration = 1.2;
      candidate = [-acceleration, -1 / acceleration, 0, 1 / acceleration, acceleration];
      epsilon = 0.00001;
      before = 100000;
      curFitness = this.computeFitness();
      postMessage({
        start: "start alg"
      });
      while (before - curFitness > epsilon) {
        before = curFitness;
        for (i = _i = 0, _ref = this.current_result.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
          if (_ref1 = Math.round(this.current_result[i][1]), __indexOf.call(this.gatesys, _ref1) < 0) {
            best = -1;
            bestScore = 1000000;
            for (j = _j = 0; _j <= 4; j = ++_j) {
              this.current_result[i][0] += stepSize[i] * candidate[j];
              temp = this.computeFitness();
              this.current_result[i][0] = this.current_result[i][0] - stepSize[i] * candidate[j];
              if (temp < bestScore) {
                bestScore = temp;
                best = j;
              }
            }
            if (candidate[best] !== 0) {
              this.current_result[i][0] += stepSize[i] * candidate[best];
              stepSize[i] *= candidate[best];
            }
          }
        }
        postMessage({
          best: this.current_result
        });
        curFitness = bestScore;
      }
      return this.init_skier;
    };

    LocalOptimization.prototype.computeFitness = function() {
      var factor, fitness, index, nextPos, result, skier, v0, x0, _i, _len, _ref;
      skier = new solver.Skier(0, null, 0, 0, null, x0 = this.startPoint, v0 = Utils.findCoords(this.current_result[0], this.startPoint, this.val));
      _ref = this.current_result;
      for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
        nextPos = _ref[index];
        skier.moveStraightToPoint(1, nextPos, 0.001);
      }
      result = this.computePunishment(this.current_result);
      factor = result.sum;
      fitness = factor * (skier.result + computeRedundantEdgeChangePunish(result.numberOfEdgeChange, 5));
      return fitness;
    };

    computeRedundantEdgeChangePunish = function(numberOfEdgeChange, numberOfGates) {
      var numberOfRedundanChanges, numberOfRightChanges, redundantChangePunish;
      numberOfRightChanges = numberOfGates - 1;
      numberOfRedundanChanges = numberOfEdgeChange - numberOfRightChanges;
      if (numberOfRedundanChanges < 0) {
        throw "Number of redundant gates wrong!";
      }
      redundantChangePunish = 2;
      return numberOfRedundanChanges * redundantChangePunish;
    };

    LocalOptimization.prototype.computePunishment = function(positions) {
      var denominator, diff, i, item, numberOfEdgeChange, numerator, punish, sum, x1, x2, x3, y1, y2, y3, _ref, _ref1, _ref2;
      i = 0;
      diff = [];
      while (i < positions.length - 2) {
        _ref = positions[i + 2], x3 = _ref[0], y3 = _ref[1];
        _ref1 = positions[i + 1], x2 = _ref1[0], y2 = _ref1[1];
        _ref2 = positions[i], x1 = _ref2[0], y1 = _ref2[1];
        denominator = (y3 - y2) * (y2 - y1);
        numerator = x1 + x3 - 2 * x2;
        diff.push(numerator / denominator);
        i += 1;
      }
      i = 0;
      punish = [];
      numberOfEdgeChange = 0;
      while (i < diff.length - 1) {
        if (diff[i + 1] * diff[i] < 0) {
          numberOfEdgeChange += 1;
        }
        i += 1;
      }
      diff = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = diff.length; _i < _len; _i++) {
          item = diff[_i];
          _results.push(Math.abs(item) * item * item);
        }
        return _results;
      })();
      sum = diff.reduce(function(t, s) {
        return t + s;
      });
      return {
        sum: sum,
        numberOfEdgeChange: numberOfEdgeChange
      };
    };

    return LocalOptimization;

  }).call(this);

  this.LocalOptimization = LocalOptimization;

  this.LocalOptimization = LocalOptimization;

}).call(this);
