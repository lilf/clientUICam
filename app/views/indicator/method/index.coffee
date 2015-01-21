IndicatorMethodView = require './method_view'

module.exports = class IndicatorMethodNode extends Backbone.Node

  requires:
    bigModes: 'bigModes'

  initialize: ->
    @method_view = new IndicatorMethodView
    $('#indicator_method_view').html @method_view.render().el

  ready: ->
    @listenTo @bigModes, 'bigModes:reset:methods', @reset

  reset: (methods) ->
    console.log methods
