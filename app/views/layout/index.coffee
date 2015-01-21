LayoutView = require './layout_view'

module.exports = class LayoutNode extends Backbone.Node

  initialize: ->
    @layout_view = new LayoutView

    $('#main_view').html @layout_view.render().el
