// Generated by CoffeeScript 1.3.3

/*
this is a hack that enables the usage of this script in both: the browser via Web Workers or in Node.js
*/


(function() {
  var B, Skier, Solver, Utils, alfa, cos, g, k1, lib, mag, pi, root, sin, sqrt, square,
    _this = this,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  lib = {};

  try {
    importScripts('./numeric.js');
    if (typeof numeric !== "undefined" && numeric !== null) {
      lib.numeric = numeric;
    }
  } catch (error) {
    lib.numeric = require("./numeric.js");
  }

  pi = Math.PI;

  sin = Math.sin;

  cos = Math.cos;

  sqrt = Math.sqrt;

  square = function(x) {
    return x * x;
  };

  mag = function(_arg) {
    var x, y;
    x = _arg[0], y = _arg[1];
    return Math.sqrt(square(x) + square(y));
  };

  g = 9.80665;

  g = 9.81;

  B = 4;

  k1 = 0.05;

  k1 = 0;

  alfa = pi / 12;

  Utils = (function() {
    /*
    	finds the coordinates from the length of the vector and 
    	tan angle of inclination of the next velocity vector with the same length
    */

    var _this = this;

    function Utils() {}

    Utils.findCoords = function(endPoint, position, length) {
      var factor, vProp, vx, vy;
      vProp = (endPoint[1] - position[1]) / (endPoint[0] - position[0]);
      factor = 1;
      if (endPoint[0] - position[0] < 0) {
        factor = -1;
      }
      vx = factor * length / (Math.sqrt(1 + vProp * vProp));
      vy = factor * vProp * length / (Math.sqrt(1 + vProp * vProp));
      return [vx, vy];
    };

    /*
    	computes length of the vector
    */


    Utils.vectorLength = function(vector) {
      return Math.sqrt(Math.pow(vector[0], 2) + Math.pow(vector[1], 2));
    };

    Utils.vectorDistance = function(vector1, vector2) {
      var xEnd, xx, xy, yEnd;
      xEnd = vector1[0], yEnd = vector1[1];
      xx = vector2[0], xy = vector2[1];
      return Utils.vectorLength([xEnd - xx, yEnd - xy]);
    };

    Utils.compute_sin_cos_beta = function(v0) {
      var cos_beta, eps, sin_beta, v0_length;
      v0_length = mag(v0);
      eps = 0.00001;
      if (v0_length <= eps) {
        cos_beta = 0.0;
        sin_beta = 1.0;
      } else {
        cos_beta = v0[0] / v0_length;
        sin_beta = v0[1] / v0_length;
      }
      return [sin_beta, cos_beta];
    };

    return Utils;

  }).call(this);

  Skier = (function() {
    /*
    	C - drag coefficient, typical values (0.4 - 1)
    	A - area of the skier exposed to the air
    */

    function Skier(mi, m, C, A, solver, x0, v0) {
      this.mi = mi != null ? mi : 0.05;
      this.m = m != null ? m : 60;
      this.C = C != null ? C : 0.6;
      this.A = A != null ? A : 0.2;
      this.solver = solver != null ? solver : new Solver();
      this.x0 = x0 != null ? x0 : [0, 0];
      this.v0 = v0 != null ? v0 : [0, 19];
      this.roh = 1.32;
      this.k2 = 0.5 * this.C * this.roh * this.A;
      this.velocities = [v0];
      this.positions = [x0];
      this.result = 0;
      this.min = 10000;
    }

    /*
    	resets all params of the skier. It's like taking him back to the starting point, after he finifhed his race
    */


    Skier.prototype.reset = function() {
      this.velocities = [this.velocities[this.velocities.length - 1]];
      this.positions = [this.positions[this.positions - 1]];
      return this.result = 0;
    };

    /*
    	Move the skier to the endPoint. It changes the skier inner state. It is not confirmed that the skier really 
    	managed to reach the proximity of that point
    */


    Skier.prototype.moveToPoint = function(kappa, endPoint, accuracy, sign_omega) {
      var reachedDestination, _results;
      if (accuracy == null) {
        accuracy = 0.01;
      }
      if (sign_omega == null) {
        sign_omega = 1;
      }
      reachedDestination = false;
      _results = [];
      while (!reachedDestination) {
        _results.push(reachedDestination = this._move(kappa, endPoint, accuracy, sign_omega));
      }
      return _results;
    };

    /*
    	Move the skier to the endPoint going in the straight line (kappa ~ 0).  It changes the skier inner state. It is not confirmed that the skier really 
    	managed to reach the proximity of that point
    */


    Skier.prototype.moveStraightToPoint = function(endPoint, accuracy, sign_omega) {
      var kappa, reachedDestination, v, _results;
      if (accuracy == null) {
        accuracy = 0.01;
      }
      if (sign_omega == null) {
        sign_omega = 1;
      }
      reachedDestination = false;
      kappa = 0;
      _results = [];
      while (!reachedDestination) {
        v = Utils.findCoords(endPoint, this.positions[0], Utils.vectorLength(this.velocities[0]));
        _results.push(reachedDestination = this._moveWithArbitraryV(v, kappa, endPoint, accuracy, sign_omega));
      }
      return _results;
    };

    /*
    	Compute new kappa that is required so that the skier read the endPoint taking current velocity vector into account. It is not guaranted that the skier really 
    	managed to reach the proximity of that point using computed kappa
    */


    Skier.prototype.computeKappa = function(endPoint) {
      var kappa, x, x1, y, y1, _ref, _ref1;
      _ref = this.positions[0], x1 = _ref[0], y1 = _ref[1];
      _ref1 = this.getCircleCenter(endPoint), x = _ref1[0], y = _ref1[1];
      kappa = 1 / (Math.sqrt(Math.pow(x1 - x, 2) + Math.pow(y1 - y, 2)));
      return kappa;
    };

    Skier.prototype.getCircleCenter = function(endPoint) {
      var vx, vy, x, x1, x2, y, y1, y2, _ref, _ref1;
      _ref = this.positions[0], x1 = _ref[0], y1 = _ref[1];
      x2 = endPoint[0], y2 = endPoint[1];
      _ref1 = this.velocities[0], vx = _ref1[0], vy = _ref1[1];
      x = (Math.pow(y2 - y1, 2) * vy - 2 * vx * x1 * (y2 - y1) + (Math.pow(x2, 2) - Math.pow(x1, 2)) * vy) / (2 * (-vx * (y2 - y1) + vy * (x2 - x1)));
      y = (-vx * (Math.pow(y2 - y1, 2) + (Math.pow(x2, 2) - Math.pow(x1, 2)))) / (2 * (-vx * (y2 - y1) + vy * (x2 - x1))) + y1;
      return [x, y];
    };

    Skier.prototype.getPosition = function() {
      return this.positions[0];
    };

    Skier.prototype.getPositions = function() {
      return this.positions;
    };

    Skier.prototype.getVelocities = function() {
      return this.velocities;
    };

    Skier.prototype._isNotCloseEnought = function(currPoint, endPoint, accuracy) {
      var xEnd, xx, xy, yEnd, _;
      if (accuracy == null) {
        accuracy = 0.01;
      }
      xEnd = endPoint[0], yEnd = endPoint[1];
      xx = currPoint[0], xy = currPoint[1], _ = currPoint[2], _ = currPoint[3];
      return Utils.vectorDistance(currPoint, endPoint) > accuracy;
    };

    Skier.prototype._doesHeReach = function(start, actualEndPoint, wannaBeEndPoint) {
      return Utils.vectorDistance(start, actualEndPoint) > Utils.vectorDistance(start, wannaBeEndPoint);
    };

    /*
    	Important method. It applies state change of the skier based on the computed result of one single step of the computation. It also decide when the skier reached the endPoint
    */


    Skier.prototype._whatIsMyResult = function(endPoint, result, accuracy) {
      var finalResult, finalTime, lastIndex, lastRow, midResult, middleTime, overTime, previousNewTime, reachedDestination, startPosition, startTime, vx, vy, xEnd, xx, xy, yEnd;
      reachedDestination = true;
      xEnd = endPoint[0], yEnd = endPoint[1];
      lastIndex = result.y.length - 1;
      lastRow = result.y[lastIndex];
      finalResult = lastRow;
      startPosition = result.y[0];
      startTime = result.x[0];
      overTime = result.x[lastIndex];
      finalTime = overTime;
      if (!(this._doesHeReach(startPosition, lastRow, endPoint))) {
        reachedDestination = false;
      } else {
        while (this._isNotCloseEnought(finalResult, [xEnd, yEnd], accuracy)) {
          previousNewTime = middleTime;
          middleTime = (startTime + overTime) / 2;
          if (previousNewTime === middleTime) {
            throw "I cannot go there with required accuracy!";
          }
          midResult = result.at([middleTime])[0];
          if (this._doesHeReach(startPosition, midResult, endPoint)) {
            overTime = middleTime;
          } else {
            startTime = middleTime;
          }
          finalResult = midResult;
          finalTime = middleTime;
        }
      }
      xx = finalResult[0], xy = finalResult[1], vx = finalResult[2], vy = finalResult[3];
      this.positions.unshift([xx, xy]);
      this.velocities.unshift([vx, vy]);
      this.result = finalTime;
      return reachedDestination;
    };

    /*
    	just show the result, without any sideeffect and changing state of the skier
    */


    /*
    	Try to compute the appriopriate time steep for the move based on the velocity vector and endPoint. The idea is to make 
    	a prediction of the time steep in which the skier would really manage to go
    	from the current point to the endPoint.
    	now, the reference is made based on the time requires to 
    	go from currrent position  to endPosition with constant acceletarion multipied with
    	our home made constant. Multiplication is needed, because there are additional friction and air resistant forces.
    	Additional fallback is added, so that the interval is never less than a given threshold
    */


    Skier.prototype._adaptSteep = function(endPoint) {
      var a, cos_beta, optimalGiantConstant, result, s, threshold, vLen, _, _ref;
      vLen = Utils.vectorLength(this.velocities[0]);
      s = Utils.vectorDistance(this.positions[0], endPoint);
      _ref = Utils.compute_sin_cos_beta(this.velocities[0]), _ = _ref[0], cos_beta = _ref[1];
      a = g * Math.sin(alfa) * cos_beta;
      optimalGiantConstant = 5;
      result = optimalGiantConstant * (Math.sqrt(vLen * vLen + 2 * a * s) - vLen) / a;
      threshold = 10;
      if (!result || result < threshold) {
        result = threshold;
      }
      return result;
    };

    Skier.prototype.moveDebug = function(kappa, endPoint, sign_omega) {
      var steep;
      if (sign_omega == null) {
        sign_omega = 1;
      }
      steep = this._adaptSteep(this.velocities[0], endPoint);
      return this.solver.solve(this.result, this.result + steep, this.positions[0], this.velocities[0], kappa, sign_omega, this);
    };

    Skier.prototype._move = function(kappa, endPoint, accuracy, sign_omega) {
      var result, steep;
      if (accuracy == null) {
        accuracy = 0.01;
      }
      if (sign_omega == null) {
        sign_omega = 1;
      }
      steep = this._adaptSteep(endPoint);
      result = this.solver.solve(this.result, this.result + steep, this.positions[0], this.velocities[0], kappa, sign_omega, this);
      return this._whatIsMyResult(endPoint, result, accuracy);
    };

    Skier.prototype._moveWithArbitraryV = function(v, kappa, endPoint, accuracy, sign_omega) {
      var result, steep;
      if (accuracy == null) {
        accuracy = 0.01;
      }
      if (sign_omega == null) {
        sign_omega = 1;
      }
      steep = this._adaptSteep(endPoint);
      result = this.solver.solve(this.result, this.result + steep, this.positions[0], v, kappa, sign_omega, this);
      return this._whatIsMyResult(endPoint, result, accuracy);
    };

    return Skier;

  })();

  Solver = (function() {
    var movementEquasion,
      _this = this;

    function Solver() {
      this.solve = __bind(this.solve, this);

    }

    movementEquasion = function(t, v, params) {
      var N, cosinus, f, f_R, f_r, kappa, sign_omega, sinus, skier, vl, vx, vy, _, _ref;
      _ = v[0], _ = v[1], vx = v[2], vy = v[3];
      _ref = [params.skier, params.kappa, params.sinus, params.cosinus, params.sign_omega], skier = _ref[0], kappa = _ref[1], sinus = _ref[2], cosinus = _ref[3], sign_omega = _ref[4];
      vl = mag([vx, vy]);
      f_R = (square(vl)) * Math.abs(kappa);
      f_r = f_R + sign_omega * g * sin(alfa) * cosinus;
      if (f_r < 0) {
        f_r = sign_omega * g * sin(alfa) * cosinus;
        f_R = 0;
      }
      N = sqrt(square(g * cos(alfa)) + square(f_R));
      return f = [vx, vy, f_r * sinus * sign_omega - (skier.mi * N + k1 / skier.m * vl + square(skier.k2 / skier.m * vl)) * cosinus, g * sin(alfa) - f_r * cosinus * sign_omega - (skier.mi * N + k1 / skier.m * vl + skier.k2 / skier.m * square(vl)) * sinus];
    };

    Solver.prototype.solve = function(start, end, x0, v0, kappa, sign_omega, skier) {
      var cosinus, params, sinus, v0_length, _ref;
      if (start == null) {
        start = 0;
      }
      if (end == null) {
        end = 1;
      }
      if (x0 == null) {
        x0 = [0, 0];
      }
      if (v0 == null) {
        v0 = [0, 19];
      }
      if (kappa == null) {
        kappa = 0.05;
      }
      if (sign_omega == null) {
        sign_omega = 1;
      }
      if (skier == null) {
        skier = new Skier();
      }
      /*
      		Air drag is proportional to the square of velocity
      		when the velocity is grater than some boundary value: B.
      		k1 and k2 factors control whether we take square or linear proportion
      */

      v0_length = mag(v0);
      if (v0_length <= B) {
        skier.k2 = 0;
      } else {
        k1 = 0;
      }
      _ref = Utils.compute_sin_cos_beta(v0), sinus = _ref[0], cosinus = _ref[1];
      params = {
        kappa: kappa,
        skier: skier,
        sinus: sinus,
        cosinus: cosinus,
        sign_omega: sign_omega
      };
      return lib.numeric.dopri(start, end, [x0[0], x0[1], v0[0], v0[1]], function(t, v) {
        return movementEquasion(t, v, params);
      });
    };

    return Solver;

  }).call(this);

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  root.OptimalGiant = {};

  root.OptimalGiant.Solver = Solver;

  this.Skier = Skier;

  /*
  vstart = [0,0.001]
  startPoint = [0,0]
  steep = 0.01
  endPoint = [10,10]
  accuracy = 0.1
  
  skier = new Skier(@mi=0.00, @m=60, @C=0.0, @A=0.2, @solver=new Solver, @x0=startPoint, @v0=vstart)
  skier.color = "red"
  kappa = skier.computeKappa(endPoint)
  skier.moveToPoint(steep, kappa, endPoint, accuracy)
  steepPositions = (x for x in skier.getPositions() by 1000).reverse()
  */


}).call(this);
