LoginView = require './login_view'

module.exports = class LoginNode extends Backbone.Node

  initialize: (@me) ->
    @login_view = new LoginView model: @me
    $('#app').html @login_view.render().el
