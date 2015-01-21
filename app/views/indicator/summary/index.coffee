IndicatorSummaryView = require './summary_view'

module.exports = class IndicatorSummaryNode extends Backbone.Node

  requires:
    indicators: 'indicators'
    bigModes: 'bigModes'

  initialize: ->
    @summary_view = new IndicatorSummaryView
    @listenTo @summary_view, 'change:mode', @changeMode
    $('#indicator_summary_view').html @summary_view.render().el

  ready: ->
    @listenTo @indicators, 'add:item', @addItem
    @listenTo @indicators, 'modes', @renderModes
    @listenTo @indicators, 'ratio', @renderRatio

    @listenTo @bigModes, 'bigModes:info', @info

  info: (data) ->
    @summary_view.renderInfo data

  changeMode: (mode_id) ->
    indicator = @getIndicator()
    indicator.filterByModeId mode_id

  addItem: (@indicator_id) ->
    indicator = @getIndicator()
    json = indicator.toJSON()
    @renderIndicator json
    @loadingRatio()

  getIndicator: ->
    @indicators.get @indicator_id

  renderModes: (modes) ->
    @summary_view.renderModes modes.toJSON()

  renderIndicator: (indicator) ->
    @summary_view.$('[name=indicator]').text indicator.name
    @summary_view.$('[name=description]').text indicator.description
    @summary_view.$('[name=unit]').text indicator.unit

  renderRatio: (indicator) ->
    console.log 'renderRatio', indicator.name

  loadingRatio: ->
    @summary_view.$('[name=latest]').html jade.t 'loading'
    @summary_view.$('[name=ratio]').html jade.t 'loading'
    @summary_view.$('[name=range]').html  jade.t 'loading'
    @summary_view.$('[name=source]').html jade.t 'loading'
