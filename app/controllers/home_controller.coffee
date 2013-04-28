Controller = require 'controllers/base/controller'
HomePageView = require 'views/home_page_view'
ProblemModel = require 'models/problem'

module.exports = class HomeController extends Controller
  historyURL: 'home'

  index: ->
    @problem = new ProblemModel()
    @view = new HomePageView @problem
