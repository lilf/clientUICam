IndicatorDateView = require './date_view'

module.exports = class IndicatorDateNode extends Backbone.Node

  requires:
    bigModes: 'bigModes'

  initialize: ->
    @collection = new Backbone.Collection
    @listenTo @collection, 'active', @active
    @date_view = new IndicatorDateView { @collection }
    $('#indicator_date_view').html @date_view.render().el

  ready: ->
    @listenTo @bigModes, 'bigModes:reset:dates', @reset

  reset: (dates) ->
    @collection.remove @collection.models
    @collection.reset dates

  active: (name) ->
    @bigModes.trigger 'bigModes:set:date', name
