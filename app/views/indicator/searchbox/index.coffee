SearchboxView = require './search_box_view'

module.exports= class SearchboxNode extends Backbone.Node

  requires:
    indicators: 'indicators'
    router: 'router'
    categories: 'categories'
    category_indicators: 'category_indicators'

  initialize: ->
    @search_box_view = new SearchboxView
    @listenTo @search_box_view, 'indicator_id', @goTo
    $('#indicator_search_box_view').html @search_box_view.render().el

  ready: ->
    @listenTo @indicators, 'add:item', @addItem
    @listenTo @indicators, 'add', @addOption
    @indicators.each @addOption, this if @indicators.length

  addItem: (indicator_id) ->
    @when 'category_indicators:sync', =>
      @search_box_view.addItem indicator_id

  addOption: (indicator) ->
    @when 'category_indicators:sync', =>
      return unless @category_indicators.findWhere indicator_id: indicator.get('_id')
      @search_box_view.addOption indicator.toJSON()

  goTo: (indicator_id) ->
    @router.toIndicator indicator_id
