'''
this is a hack that enables the usage of this script in both: the browser via Web Workers or in Node.js
'''
lib = {}
try
  importScripts './numeric.js'
  if numeric?
    lib.numeric = numeric
catch error
  lib.numeric = require("./numeric.js")
  
pi = Math.PI
sin = Math.sin
cos = Math.cos
sqrt = Math.sqrt
square = (x) => x*x
mag = ( [x,y]) => Math.sqrt(square(x) + square(y))
g = 9.80665 # standard acceleration of free fall

sign_omega = -1
B = 4 #  boundary value (in m/s) from with air drag becomes proportional to the square of the velocity
k1 = 0.05 # out of space driven value

alfa = pi/6

class Skier
  """
  C - drag coefficient, typical values (0.4 - 1)
  A - area of the skier exposed to the air
  """
  constructor: (@mi=0.05, @m=60, @C=0.6, @A=0.2) ->
    this.roh = 1.32 # air density
    @k2 = 0.5 * @C * this.roh * @A

class Solver
  compute_sin_cos_beta = (v0) =>
    v0_length = mag(v0)
    eps = 0.00001
    if v0_length<=eps
      cos_beta=0.0
      sin_beta=1.0
    else
      cos_beta =  v0[0]/v0_length
      sin_beta = v0[1]/v0_length
    [sin_beta, cos_beta]
    
  vectorfield = (t,v, params) =>
    [_, _, vx, vy] = v
    [skier, kappa, sinus, cosinus] = [params.skier, params.kappa, params.sinus, params.cosinus]
    vl = mag [vx,vy]
    f_R = (square(vl))*Math.abs(kappa)
    f_r = f_R + sign_omega*g*sin(alfa)*cosinus
    if f_r < 0
      f_r = sign_omega*g*sin(alfa)*cosinus
      f_R = 0  
    N = sqrt ( square((g*cos(alfa))) + square((f_R)) )
    f = [ vx, vy, f_r*sinus*sign_omega- (skier.mi*N + k1/skier.m*vl + square(skier.k2/skier.m*vl))*cosinus, g*sin(alfa) - f_r*cosinus*sign_omega - (skier.mi*N + k1/skier.m*vl + skier.k2/skier.m*square(vl))*sinus]
    
  solve : (start=0, end=1, v0=[0,0,0,19], _kappa=0.05, _skier=new Skier()) =>
    '''
    Air drag is proportional to the square of velocity
    when the velocity is grater than some boundary value: B.
    k1 and k2 factors control whether we take square or linear proportion
    '''
    v0_length = mag v0
    if v0_length <= B
      skier.k2 = 0
    else
      k1 = 0
    [_sinus, _cosinus] = compute_sin_cos_beta(v0)
    params = {kappa: _kappa, skier: _skier, sinus: _sinus, cosinus: _cosinus}
    lib.numeric.dopri_params(start,end,v0, vectorfield, params)  

root = exports ? this
root.OptimalGiant = {}
root.OptimalGiant.solver = new Solver().solve
	
# v0 = [0,0,0,19]                                              
# kappa = 1.0/20                                             
# start = Date.now()                                         
# result = new Solver().solve(0,1,v0,kappa, skier=new Skier())                              
# duration = Date.now() - start  
# console.log result                           
                                  
                                                             