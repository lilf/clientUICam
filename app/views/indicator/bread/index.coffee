IndicatorBreadView = require './bread_view'

module.exports = class IndicatorBreadNode extends Backbone.Node

  requires:
    indicators: 'indicators'
    categories: 'categories'
    category_indicators: 'category_indicators'
    bigs: 'bigs'
    router: 'router'

  initialize: ->
    @bread_view = new IndicatorBreadView
    @listenTo @bread_view, 'router:to:category', @routerToCategory
    $('#indicator_bread_view').html @bread_view.render().el

  ready: ->
    @listenTo @indicators, 'add:item', @addItem

  routerToCategory: (big_id, category_id) ->
    @router.toCategory big_id, category_id

  addItem: (indicator_id) ->
    @when 'indicators:sync', 'categories:sync', 'category_indicators:sync', -> @getNames indicator_id

  getNames:  (indicator_id) ->
    indicator = @indicators.get indicator_id
    category_indicator = @category_indicators.findWhere { indicator_id }
    return @bread_view.setBread indicator_name: indicator.get 'name' unless category_indicator
    category = @categories.get category_indicator.get 'category_id'
    big = @bigs.find (big) -> _.contains big.get('children'), category.get('name')
    json =
      indicator_name: indicator.get 'name'
      category_name: category.get 'name'
      big_name: big.get 'name'
      category_id: category.get '_id'
      big_id: big.get '_id'

    @bread_view.setBread json

