// Generated by CoffeeScript 1.3.3
(function() {
  'this is a hack that enables the usage of this script in both: the browser via Web Workers or in Node.js';

  var B, Skier, Solver, alfa, cos, g, k1, lib, mag, pi, root, sin, sqrt, square,
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

  B = 4;

  k1 = 0.05;

  alfa = pi / 6;

  Skier = (function() {
    "C - drag coefficient, typical values (0.4 - 1)\nA - area of the skier exposed to the air";

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
    }

    Skier.prototype.move = function(t0, t1, kappa, sign_omega) {
      var result, vx, vy, xx, xy, _ref;
      if (sign_omega == null) {
        sign_omega = 1;
      }
      result = this.solver.solve(t0, t1, this.positions[0], this.velocities[0], kappa, sign_omega, this).y;
      _ref = result[result.length - 1], xx = _ref[0], xy = _ref[1], vx = _ref[2], vy = _ref[3];
      this.positions.unshift([xx, xy]);
      return this.velocities.unshift([vx, vy]);
    };

    Skier.prototype.getPositions = function() {
      return this.positions;
    };

    Skier.prototype.getVelocities = function() {
      return this.velocities;
    };

    return Skier;

  })();

  Solver = (function() {
    var compute_sin_cos_beta, vectorfield,
      _this = this;

    function Solver() {
      this.solve = __bind(this.solve, this);

    }

    compute_sin_cos_beta = function(v0) {
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

    vectorfield = function(t, v, params) {
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
      'Air drag is proportional to the square of velocity\nwhen the velocity is grater than some boundary value: B.\nk1 and k2 factors control whether we take square or linear proportion';

      v0_length = mag(v0);
      if (v0_length <= B) {
        skier.k2 = 0;
      } else {
        k1 = 0;
      }
      _ref = compute_sin_cos_beta(v0), sinus = _ref[0], cosinus = _ref[1];
      params = {
        kappa: kappa,
        skier: skier,
        sinus: sinus,
        cosinus: cosinus,
        sign_omega: sign_omega
      };
      return lib.numeric.dopri_params(start, end, [x0[0], x0[1], v0[0], v0[1]], vectorfield, params);
    };

    return Solver;

  }).call(this);

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  root.OptimalGiant = {};

  root.OptimalGiant.Solver = Solver;

  root.OptimalGiant.Skier = Skier;

  'start = Date.now()                                                                    \n\nsk = new Skier()\nn = 0\nsteep = 0.1\nt0 = 0\nwhile n < 1000\n  t1 = t0+steep\n  sk.move(t0, t1, 0.05)\n  t0 = t1\n  n += 1\n\nduration = Date.now() - start\nconsole.log sk.getPositions().reverse() ';


}).call(this);
