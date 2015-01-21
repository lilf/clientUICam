config = require 'config'

IndicatorHotView = require './hot_view'
module.exports = class IndicatorHotNode extends Backbone.Node

  requires:
    indicators: 'indicators'
    router: 'router'
    categories: 'categories'
    category_indicators: 'category_indicators'

  initialize: ->
    @collection = new Backbone.Collection
    @listenTo @collection, 'indicator_id', @switchIndicator
    @hot_view = new IndicatorHotView {@collection}
    $('#indicator_hot_view').html @hot_view.render().el

  ready: ->
    @listenTo @indicators, 'sync', @fetchHot
    @ask()

  ask: ->
    @indicators.trigger 'sync' if @indicators.length

  switchIndicator: (indicator_id) ->
    @router.toIndicator indicator_id

  fetchHot: ->
    url = config.api.baseUrl + '/logs/hot-indicators'
    @when 'category_indicators:sync', => $.get url, @hot

  hot: (data) =>
    { indicators, category_indicators } = this
    results = _.chain data
      .filter (d) -> indicators.get(d._id) and category_indicators.findWhere(indicator_id: d._id)
      .map (d) ->
        indicator = indicators.get d._id
        json = indicator.toJSON()
        json.rank = d.value
        json
      .sortBy 'rank'
      .value()
      .reverse()
      .slice(0, 10)

    results = _.map results, (d, i) ->
        d.rankNum = i + 1
        d

    @collection.add results
