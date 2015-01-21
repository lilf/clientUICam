config = require 'config'

class CategoryIndicator extends Backbone.Model

  idAttribute: '_id'

module.exports = class CategoryIndicators extends Backbone.Collection

  model: CategoryIndicator

  url: ->
    config.api.baseUrl + '/category_indicators'

  getCategoryIds: (indicator_id) ->
    category_indicator = @findWhere { indicator_id }
    return false unless category_indicator
    category_id = category_indicator.get 'category_id'
    @getIndicatorIds category_id

  getIndicatorIds: (category_id) ->
    category_indicators = @where { category_id }
    _.map category_indicators,  (_category_indicator) -> _category_indicator.get 'indicator_id'
