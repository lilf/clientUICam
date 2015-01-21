LogoView  = require './logo_view'
module.exports = class LogoNode extends Backbone.Node

  initialize: ->
    @logo_view = new LogoView
    $('#logo_view').html @logo_view.render().el
