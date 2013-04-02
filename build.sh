coffee --compile --output public/javascripts/ worker/turnWorker.coffee
coffee --compile --output public/javascripts/ worker/worker.coffee
coffee --compile --output public/javascripts/ worker/solver.coffee
coffee --compile --output public/javascripts/ worker/optimizePoints.coffee
coffee --compile --output public/javascripts/ worker/evolutionAlgorithm.coffee
coffee --compile --output public/javascripts/ worker/localOptAlgorithm.coffee
coffee --compile --output public/javascripts/ worker/statistics.coffee
coffee --compile --output public/javascripts/ worker/gate.coffee
cp worker/gauss.js public/javascripts/gauss.js
cp worker/numeric.js public/javascripts/numeric.js
cp worker/underscore.js public/javascripts/underscore.js
brunch build