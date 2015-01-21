FooterView = require './footer_view'
module.exports = class FooterNode extends Backbone.Node

  initialize: ->
    @footer_view = new FooterView
    $('#footer_view').html @footer_view.render().el
