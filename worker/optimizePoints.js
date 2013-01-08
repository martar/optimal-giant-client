// Generated by CoffeeScript 1.3.3
(function() {
  var PointTurns, PointsSet, evol, findCoords, gates_indices, solver,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  importScripts('./underscore.js');

  importScripts('./solver.js');

  importScripts('./evolutionAlgorithm.js');

  importScripts('./gauss.js');

  evol = {};

  evol.Individual = Individual;

  solver = {};

  solver.Skier = Skier;

  /*
  _ = require('./underscore.js')
  solver = require('./solver.js')
  evol = require('./evolutionAlgorithm.js')
  gauss = require('./gauss.js')
  */


  findCoords = function(value, length) {
    var coor, vProp;
    coor = [];
    vProp = Math.tan(value);
    coor.push(length / (Math.sqrt(1 + vProp * vProp)));
    coor.push(vProp * length / (Math.sqrt(1 + vProp * vProp)));
    return coor;
  };

  gates_indices = [];

  PointTurns = (function() {

    function PointTurns(del_y, count, val, gates, startPoint) {
      this.del_y = del_y;
      this.count = count;
      this.val = val;
      this.gates = gates;
      this.startPoint = startPoint != null ? startPoint : [0, 0];
      this.idvs = [];
      this.getInitialPop();
    }

    PointTurns.prototype.getInitialPop = function() {
      var cur_y, gate, i, ind_i, init_dev, points, skier, startPoint, v0, x0, x_range, _i, _j, _len, _ref, _ref1, _results;
      init_dev = 1;
      _results = [];
      for (ind_i = _i = 1, _ref = this.count; 1 <= _ref ? _i <= _ref : _i >= _ref; ind_i = 1 <= _ref ? ++_i : --_i) {
        startPoint = null;
        points = [];
        cur_y = this.del_y;
        i = 0;
        _ref1 = this.gates;
        for (_j = 0, _len = _ref1.length; _j < _len; _j++) {
          gate = _ref1[_j];
          if (startPoint === null) {
            startPoint = this.startPoint;
          }
          if (startPoint[0] > gate[0]) {
            x_range = [gate[0], startPoint[0]];
          } else {
            x_range = [startPoint[0], gate[0]];
          }
          while (cur_y < gate[1]) {
            points.push([Math.random() * (x_range[1] - x_range[0]) + x_range[0], cur_y, init_dev]);
            cur_y += this.del_y;
            i += 1;
          }
          cur_y = gate[1] + this.del_y;
          points.push(gate.slice(0));
          if (ind_i === 1) {
            gates_indices.push(i);
          }
          startPoint = gate;
          i += 1;
        }
        skier = new solver.Skier(0, null, 0, 0, null, x0 = this.startPoint, v0 = findCoords(0, this.val));
        _results.push(this.idvs.push(new PointsSet(points, skier)));
      }
      return _results;
    };

    return PointTurns;

  })();

  PointsSet = (function(_super) {

    __extends(PointsSet, _super);

    function PointsSet(points, skier) {
      this.skier = skier;
      this.computePunishFactor = __bind(this.computePunishFactor, this);

      this.computePunishment = __bind(this.computePunishment, this);

      this.setValue(points);
    }

    PointsSet.prototype.setValue = function(value) {
      var pos, vel;
      this.fitness = null;
      this.value = value;
      if (typeof skier !== "undefined" && skier !== null) {
        pos = this.skier.getPositions().reverse()[0];
        this.skier.positions = [pos[0], pos[1]];
        vel = this.skier.getVelocities().reverse()[0];
        this.skier.velocities = [vel[0], vel[1]];
      }
      return this.computeFitness();
    };

    PointsSet.prototype.computePunishment = function(positions) {
      var curr, denominator, diff, i, item, magicalFactor, next, numerator, punish, punishment, sum, x1, x2, x3, y1, y2, y3, _ref, _ref1, _ref2;
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
      punish.push(diff[0]);
      magicalFactor = 1.5;
      while (i < diff.length - 1) {
        next = diff[i + 1];
        curr = diff[i];
        punishment = diff[i + 1];
        if (next * curr < 0) {
          punishment = punishment * magicalFactor;
        }
        punish.push(punishment);
        i += 1;
      }
      punish = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = punish.length; _i < _len; _i++) {
          item = punish[_i];
          _results.push(Math.abs(item) * item * item);
        }
        return _results;
      })();
      sum = punish.reduce(function(t, s) {
        return t + s;
      });
      return sum;
    };

    PointsSet.prototype.computePunishFactor = function(positions) {
      var a, abx, aby, angba, angbc, angle, b, c, cbx, cby, i, punishFactors, rslt;
      i = 0;
      punishFactors = [];
      while (i < positions.length - 2) {
        a = positions[i];
        b = positions[i + 1];
        c = positions[i + 2];
        abx = b[0] - a[0];
        aby = b[1] - a[1];
        cbx = b[0] - c[0];
        cby = b[1] - c[1];
        angba = Math.atan2(aby, abx);
        angbc = Math.atan2(cby, cbx);
        rslt = angba - angbc;
        angle = (rslt * 180) / 3.141592;
        if (angle > 180) {
          angle = 360 - angle;
        }
        punishFactors.push(1 - Math.pow((angle / 180.0) - 1.5, 6));
        i += 1;
      }
      return punishFactors;
    };

    PointsSet.prototype.computeFitness = function() {
      var index, interval, nextPos, punishFactors, t, _i, _len, _ref;
      if (this.fitness) {
        return this.fitness;
      }
      interval = 0.1;
      t = 0;
      this.min = 100000;
      punishFactors = this.computePunishFactor(this.value);
      _ref = this.value;
      for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
        nextPos = _ref[index];
        this.skier.moveStraightToPoint(punishFactors[index], nextPos, 0.001);
      }
      this.skier.punish = punishFactors;
      return this.fitness = this.skier.result;
    };

    PointsSet.prototype.createCopy = function(changedPoints) {
      var firstPos, firstVel, skierPos, skierVel, v0, x0;
      skierPos = this.skier.getPositions();
      firstPos = skierPos[skierPos.length - 1];
      skierVel = this.skier.getVelocities();
      firstVel = skierVel[skierVel.length - 1];
      return new PointsSet(changedPoints, new solver.Skier(0, null, 0, 0, null, x0 = [firstPos[0], firstPos[1]], v0 = [firstVel[0], firstVel[1]]));
    };

    'mutate individual\ngaussAll - nrand value used for whole population in one iteration\ntau, tau_prim - parameters of evolutionary algorithm';


    PointsSet.prototype.mutate = function(gaussAll, tau, tau_prim) {
      var diff, gauss, i, ind, indCount, newValue, _i;
      indCount = Math.floor(Math.random() * (this.value.length - 1));
      newValue = (function() {
        var _i, _len, _ref, _results;
        _ref = this.value;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          i = _ref[_i];
          _results.push([i[0], i[1], i[2]]);
        }
        return _results;
      }).call(this);
      for (i = _i = 1; 1 <= indCount ? _i <= indCount : _i >= indCount; i = 1 <= indCount ? ++_i : --_i) {
        ind = Math.floor(Math.random() * (this.value.length - 1));
        while ((__indexOf.call(gates_indices, ind) >= 0)) {
          ind = Math.floor(Math.random() * (this.value.length - 1));
        }
        gauss = Math.nrand();
        newValue[ind][2] = newValue[ind][2] * Math.exp(tau_prim * gaussAll + tau * gauss);
        gauss = Math.nrand();
        diff = newValue[ind][2] * gauss;
        newValue[ind][0] += diff;
      }
      return this.createCopy(newValue);
    };

    PointsSet.prototype.cross = function(b) {
      var i;
      return this.createCopy((function() {
        var _i, _ref, _results;
        _results = [];
        for (i = _i = 0, _ref = this.value.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
          _results.push([(this.value[i][0] + b.value[i][0]) / 2, this.value[i][1], this.value[i][2]]);
        }
        return _results;
      }).call(this));
    };

    return PointsSet;

  })(evol.Individual);

  this.PointTurns = PointTurns;

  "pop = new PointTurns(1,20,1,[10,10])\n#console.log \"nowa populacja:\"\nfor i in pop.idvs.reverse()\n	console.log i.fitness\n	#for a in i.value\n	#console.log a\n\n#console.log ({fitness: i.fitness,points: ([a[0],a[1]] for a in i.value)} for i in pop.idvs.reverse())\n\n\nb = new evol.Optimization(pop,20,5).compute()\nconsole.log (i.fitness for i in pop.idvs.reverse())\nconsole.log b";


}).call(this);
