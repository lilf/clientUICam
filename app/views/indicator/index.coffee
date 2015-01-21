IndicatorView = require './indicator_view'
BigModes = require './big_modes'

module.exports = class IndicatorNode extends Backbone.Node

  requires:
    indicators: 'indicators'

  defines:
    bigModes: 'bigModes'

  initialize: ->
    @bigModes = new BigModes
    @indicator_view = new IndicatorView
    $('#main_view').html @indicator_view.render().el

  ready: (params) ->
    indicator_id = params[0]
    @smartAddItem indicator_id

  restart: (params) ->
    indicator_id = params[0]
    @smartAddItem indicator_id

  addItem: (indicator_id) ->
    @indicators.trigger 'add:item', indicator_id
    indicator = @indicators.get indicator_id
    @domainPub 'log', 'visit', 'indicator', indicator_id, indicator.toJSON()
    @indicators.trigger 'render:item', indicator
    # @bigModes.listenToOnce indicator, 'bigModes', @bigModes.reset
    # indicator.fetchAll()

  smartAddItem: (indicator_id) ->
    return unless indicator_id # how to choose default value if indicator_id not exist
    if @indicators.length
      @addItem indicator_id
    else
      @listenToOnce @indicators, 'sync', => @addItem indicator_id
