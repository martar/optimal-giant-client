Math.nrand = function() {
	var x1, x2, rad;
 
	do {
		x1 = 2 * this.random() - 1;
		x2 = 2 * this.random() - 1;
		rad = x1 * x1 + x2 * x2;
	} while(rad >= 1 || rad == 0);
 
	var c = this.sqrt(-2 * Math.log(rad) / rad);
 
	return x1 * c;
};
