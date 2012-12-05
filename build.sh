coffee --compile --output public/javascripts/ worker/turnWorker.coffee
coffee --compile --output public/javascripts/ worker/worker.coffee
coffee --compile --output public/javascripts/ worker/brach.coffee
coffee --compile --output public/javascripts/ worker/solver.coffee
coffee --compile --output public/javascripts/ worker/optimizePoints.coffee
coffee --compile --output public/javascripts/ worker/evolutionAlgorithm.coffee
cp worker/numeric.js public/javascripts/numeric.js
cp worker/underscore.js public/javascripts/underscore.js
brunch build