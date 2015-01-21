IndicatorFilterView = require './filter_view'

module.exports = class IndicatorFilterNode extends Backbone.Node

  requires:
    bigModes: 'bigModes'

  initialize: ->
    @filter_view = new IndicatorFilterView
    $('#indicator_filter_view').html @filter_view.render().el

  ready: ->
    @listenTo @bigModes, 'bigModes:reset:filters', @reset

  reset: (filters) ->
    console.log filters
