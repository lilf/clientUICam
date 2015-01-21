Indicators = require 'models/indicators'
IndicatorListView = require './list_view'

module.exports = class IndicatorListNode extends Backbone.Node

  requires:
    indicators: 'indicators'
    categories: 'categories'
    category_indicators: 'category_indicators'
    bigs: 'bigs'
    router: 'router'

  initialize: ->
    @collection = new Indicators
    @list_view = new IndicatorListView { @collection }
    $('#indicator_list_view').html @list_view.render().el

  ready: ->
    @listenTo @collection, 'indicator_id', @switchIndicator
    @listenTo @categories, 'active_id', @active

  active: ->
    @when 'categories:active_id', 'indicators:sync', 'categories:sync', 'category_indicators:sync', @render2

  render2: (category_id) ->
    return unless category_id
    indicator_ids = @category_indicators.getIndicatorIds category_id
    indicators = @getIndicators indicator_ids
    @collection.reset indicators

  switchIndicator: (indicator_id) ->
    @router.toIndicator indicator_id

  getIndicators: (indicator_ids) ->
    @collection.remove @collection.models
    _.chain indicator_ids
      .map (indicator_id) => @indicators.get indicator_id
      .compact()
      # .each (model) => model.toJSON()
      .value()


