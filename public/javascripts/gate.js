// Generated by CoffeeScript 1.3.3
(function() {
  var Gate, Point,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Point = (function() {

    function Point(x, y, dev) {
      this.x = x;
      this.y = y;
      this.dev = dev != null ? dev : 1;
    }

    Point.prototype.createCopy = function() {
      return new Point(this.x, this.y, this.dev);
    };

    Point.prototype.correct = function() {
      return true;
    };

    return Point;

  })();

  Gate = (function(_super) {

    __extends(Gate, _super);

    function Gate(gate, left, dev, gate_x, gate_y) {
      this.left = left;
      this.dev = dev != null ? dev : 1;
      this.gate_x = gate_x != null ? gate_x : 0;
      this.gate_y = gate_y != null ? gate_y : 0;
      Gate.__super__.constructor.call(this, gate[0][0], gate[0][1]);
      if (this.gate_x === 0 && this.gate_y === 0) {
        this.gate_x = this.x;
        this.gate_y = this.y;
      }
      this.closed = gate[1];
    }

    Gate.prototype.createCopy = function() {
      return new Gate([[this.x, this.y], this.closed], this.left, this.dev, this.gate_x, this.gate_y);
    };

    Gate.prototype.correct = function() {
      if (this.left === 0) {
        return this.x <= this.gate_x + 6 && this.gate_x <= this.x;
      } else {
        return this.gate_x - 6 <= this.x && this.x <= this.gate_x;
      }
    };

    return Gate;

  })(Point);

  this.Gate = Gate;

  this.Point = Point;

}).call(this);
