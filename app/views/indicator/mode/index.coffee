IndicatorModeView = require './mode_view'

module.exports = class IndicatorModeNode extends Backbone.Node

  requires:
    bigModes: 'bigModes'

  initialize: ->
    @collection = new Backbone.Collection
    @listenTo @collection, 'active', @active
    @mode_view = new IndicatorModeView { @collection }
    $('#indicator_mode_view').html @mode_view.render().el

  ready: ->
    @listenTo @bigModes, 'bigModes:reset:modes', @reset

  reset: (modes) ->
    @collection.remove @collection.models
    @collection.reset modes

  active: (name) ->
    @bigModes.trigger 'bigModes:set:mode', name
