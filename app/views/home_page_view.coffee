template = require 'views/templates/home'
PageView = require 'views/base/page_view'

module.exports = class HomePageView extends PageView
  template: template
  className: 'home-page'
  initialize: ->
    super
    worker = new Worker 'javascripts/worker.js'
    worker.onmessage = (event) =>
      console.log event.data
      alert "Computations finished in #{event.data[0]} seconds"
    data = {v0: [0,19], kappa: 1.0/20}
    worker.postMessage(data)
