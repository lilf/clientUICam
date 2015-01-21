IndicatorRelatedView = require './related_view'
module.exports = class IndicatorRelatedNode extends Backbone.Node

  requires:
    router: 'router'
    indicators: 'indicators'
    categories: 'categories'
    category_indicators: 'category_indicators'

  initialize: ->
    @collection = new Backbone.Collection
    @listenTo @collection, 'indicator_id', @switchIndicator
    @related_view = new IndicatorRelatedView {@collection}
    $('#indicator_related_view').html @related_view.render().el

  ready: ->
    @listenTo @indicators, 'add:item', @addItem
    # @listenWhen 'indicators:add:item category_indicators:sync', @fetchRelated
  #   @ask()

  # ask: ->
  #   @category_indicators.trigger 'sync' if @category_indicators.length

  switchIndicator: (indicator_id) ->
    @router.toIndicator indicator_id

  addItem: (indicator_id) ->
    @indicator_id = indicator_id
    @smartFetch()

  smartFetch: ->
    if @category_indicators.length
      @fetchRelated()
    else
      @listenToOnce @category_indicators, 'sync', @fetchRelated


  fetchRelated: ->
    indicator_ids = @category_indicators.getCategoryIds @indicator_id
    results = _.chain indicator_ids
      .map (_id) => @indicators.get _id
      .compact()
      .map (indicator) -> indicator.toJSON()
      .reject (indicator) => indicator._id is @indicator_id
      .value()

    @collection.remove @collection.models
    @collection.add results
    @showLength @collection.length

  showLength: (length) ->
    @related_view.$('.related-indicator-length').text length
