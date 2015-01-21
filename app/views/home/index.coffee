HomeView = require './home_view'
module.exports = class HomeNode extends Backbone.Node

  initialize: ->
    @home_view = new HomeView
    $('#main_view').html @home_view.render().el
