// Generated by CoffeeScript 1.4.0
(function() {
  var Individual, K, Optimization, Turn, Turns, tau, tau_prim,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  importScripts('./underscore.js');

  importScripts('./solver.js');

  importScripts('./statistics.js');

  importScripts('./gauss.js');

  /*
  _ = require('./underscore.js')
  require('./solver.js')
  */


  K = 1;

  tau = function(n) {
    return K / (Math.sqrt(2 * n));
  };

  tau_prim = function(n) {
    return K / (Math.sqrt(2 * Math.sqrt(n)));
  };

  Turns = (function() {

    function Turns(count, val, endPoint) {
      var i, propEnd, x;
      propEnd = endPoint[1] / endPoint[0];
      x = Math.atan(propEnd);
      this.idvs = (function() {
        var _i, _results;
        _results = [];
        for (i = _i = 1; 1 <= count ? _i <= count : _i >= count; i = 1 <= count ? ++_i : --_i) {
          _results.push(new Turn(val, Math.random() * (Math.PI / 2 - Math.abs(x)) + Math.abs(x), endPoint));
        }
        return _results;
      })();
    }

    return Turns;

  })();

  Individual = (function() {

    function Individual(value) {
      this.setValue(value);
    }

    Individual.prototype.setValue = function(value) {
      this.value = value;
      return this.computeFitness();
    };

    Individual.prototype.createCopy = function(changedValue) {
      return new Individual(changedValue);
    };

    Individual.prototype.computeFitness = function() {
      return this.fitness = Math.sin(this.value);
    };

    'Create new individual which value varies +- percentValue% of value';


    Individual.prototype.mutate = function(percentValue) {
      var newValue;
      newValue = this.value + (Math.random() * percentValue * 2 - percentValue) * this.value / 100;
      return this.createCopy(newValue);
    };

    'Cross this ind with ind b\nThe new Individual has the average value of these two.';


    Individual.prototype.cross = function(b) {
      return this.createCopy((this.value + b.value) / 2);
    };

    return Individual;

  })();

  Turn = (function(_super) {

    __extends(Turn, _super);

    function Turn(length, alpha, endPoint, startPoint) {
      this.length = length;
      this.endPoint = endPoint;
      this.startPoint = startPoint != null ? startPoint : [0, 0];
      this.setValue(alpha);
    }

    Turn.prototype.setValue = function(value) {
      var v0, x0;
      this.fitness = null;
      this.value = value;
      this.skier = new Skier(null, null, null, null, null, x0 = this.startPoint, v0 = this.findCoords());
      return this.computeFitness();
    };

    Turn.prototype.computeFitness = function() {
      var curPos, interval, kappa, t;
      throw "THIS CODE SHOULD NOT BE USED";
      if (this.fitness) {
        return this.fitness;
      }
      interval = 0.0001;
      t = 0;
      this.min = 100000;
      kappa = this.computeKappa();
      curPos = this.startPoint;
      while (!this.isNear(curPos)) {
        this.skier.move(t, t + interval, kappa, 1);
        t += interval;
        curPos = this.skier.getPositions()[0];
      }
      t -= interval;
      return this.fitness = t;
    };

    'Check if we are in the closest point to the endPoint\nIt is the condition to stop simulation';


    Turn.prototype.isNear = function(x) {
      var rKw;
      rKw = Math.pow(x[0] - this.endPoint[0], 2) + Math.pow(x[1] - this.endPoint[1], 2);
      if (rKw < this.min) {
        this.min = rKw;
        return false;
      }
      return true;
    };

    Turn.prototype.createCopy = function(changedValue) {
      return new Turn(this.length, changedValue, this.endPoint);
    };

    'Compute new kappa basing on set points and velocity vector';


    Turn.prototype.computeKappa = function() {
      var kappa, vx, vy, x, x1, x2, y, y1, y2, _ref, _ref1, _ref2;
      _ref = this.startPoint, x1 = _ref[0], y1 = _ref[1];
      _ref1 = this.endPoint, x2 = _ref1[0], y2 = _ref1[1];
      _ref2 = this.findCoords(), vx = _ref2[0], vy = _ref2[1];
      x = (Math.pow(y2 - y1, 2) * vy - 2 * vx * x1 * (y2 - y1) + (Math.pow(x2, 2) - Math.pow(x1, 2)) * vy) / (2 * (-vx * (y2 - y1) + vy * (x2 - x1)));
      y = (-vx * (Math.pow(y2 - y1, 2) + (Math.pow(x2, 2) - Math.pow(x1, 2)))) / (2 * (-vx * (y2 - y1) + vy * (x2 - x1))) + y1;
      kappa = 1 / (Math.sqrt(Math.pow(x1 - x, 2) + Math.pow(y1 - y, 2)));
      return kappa;
    };

    'finds the coordinates from the length of the vector and \ntan angle of inclination of the velocity vector';


    Turn.prototype.findCoords = function() {
      var coor, vProp;
      coor = [];
      vProp = Math.tan(this.value);
      coor.push(this.length / (Math.sqrt(1 + vProp * vProp)));
      coor.push(vProp * this.length / (Math.sqrt(1 + vProp * vProp)));
      return coor;
    };

    return Turn;

  })(Individual);

  Optimization = (function() {
    'args: \n	initial population\n	number of the elements to be crossed in each iteration\n	mutationProb = 1/probability of the mutation of each element';

    function Optimization(popul, nrOfCrossed, mutationProb) {
      this.popul = popul;
      this.nrOfCrossed = nrOfCrossed;
      this.mutationProb = mutationProb;
      this.size = this.popul.idvs.length;
      this.stats = new Stats();
      this.tau = tau(this.size);
      this.tau_prim = tau_prim(this.size);
    }

    'The core function which mainpulates the population to find the best individual';


    Optimization.prototype.compute = function() {
      var bestResults, crossedInd, i, ind, mutatedInd, theBest, theWorst, trol;
      i = 0;
      this.popul.idvs = _.sortBy(this.popul.idvs, 'fitness');
      bestResults = (function() {
        var _i, _j, _len, _len1, _results;
        _results = [];
        while (!this.stop()) {
          crossedInd = this.crossPop();
          mutatedInd = this.mutatePop();
          for (_i = 0, _len = crossedInd.length; _i < _len; _i++) {
            ind = crossedInd[_i];
            this.popul.idvs.push(ind);
            postMessage({
              type: 'intermediate',
              best: ind.skier.positions
            });
          }
          for (_j = 0, _len1 = mutatedInd.length; _j < _len1; _j++) {
            ind = mutatedInd[_j];
            this.popul.idvs.push(ind);
            postMessage({
              type: 'intermediate',
              best: ind.skier.positions,
              pts: ind.value
            });
          }
          this.popul.idvs = _.sortBy(this.popul.idvs, 'fitness');
          this.popul.idvs = this.popul.idvs.slice(0, +(this.size - 1) + 1 || 9e9);
          i += 1;
          theBest = this.popul.idvs[0].fitness;
          theWorst = this.popul.idvs[this.size - 1].fitness;
          trol = postMessage({
            type: 'intermediate',
            best: this.popul.idvs[0].skier.positions
          });
          _results.push([theBest, theWorst]);
        }
        return _results;
      }).call(this);
      return bestResults;
    };

    'Do nrOfCrossed crossings between random individuals';


    Optimization.prototype.crossPop = function() {
      var a, i, it, j, newInd, _i, _ref;
      newInd = [];
      if (this.nrOfCrossed < 1) {
        return newInd;
      }
      for (it = _i = 1, _ref = this.nrOfCrossed; 1 <= _ref ? _i <= _ref : _i >= _ref; it = 1 <= _ref ? ++_i : --_i) {
        i = Math.floor(Math.random() * this.size);
        j = Math.floor(Math.random() * this.size);
        a = this.popul.idvs[i].cross(this.popul.idvs[j]);
        newInd.push(a);
      }
      return newInd;
    };

    Optimization.prototype.mutatePop = function() {
      var gaussAll, ifMut, ind, mutIds, _i, _len, _ref;
      mutIds = [];
      gaussAll = Math.nrand();
      _ref = this.popul.idvs;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        ind = _ref[_i];
        ifMut = Math.floor(Math.random() * this.mutationProb);
        if (ifMut % this.mutationProb === 0) {
          mutIds.push(ind.mutate(gaussAll, this.tau, this.tau_prim));
        }
      }
      return mutIds;
    };

    'Stoping condition';


    Optimization.prototype.stop = function() {
      var theBest, theWorst;
      theWorst = this.popul.idvs[this.size - 1];
      theBest = this.popul.idvs[0];
      postMessage({
        type: "",
        b: theBest.fitness,
        w: theWorst.fitness,
        diff: (theBest.fitness - theWorst.fitness) / theBest.fitness
      });
      return (Math.abs(theBest.fitness - theWorst.fitness) / theBest.fitness) < 0.00001;
    };

    return Optimization;

  })();

  this.Turns = Turns;

  this.Optimization = Optimization;

  this.Individual = Individual;

  'pop = new Turns(10,10,[4,5])\nconsole.log "nowa populacja:"\nconsole.log ([i.fitness,i.value] for i in pop.idvs.reverse())\n\nnew Optimization(pop,20,2).compute()\nconsole.log ([i.fitness,i.value] for i in pop.idvs.reverse())';


}).call(this);
