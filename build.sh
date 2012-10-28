coffee --compile --output public/javascripts/ worker/worker.coffee
coffee --compile --output public/javascripts/ worker/solver.coffee
cp worker/numeric.js public/javascripts/numeric.js
brunch build