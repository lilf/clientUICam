ItemView = require './item_view'

module.exports = class IndicatorHotView extends Backbone.View

  template: require './templates/hot'

  initialize: ->
    @listenTo @collection, 'add', @renderItem

  render: ->
    @$el.html @template()
    @$list = @$ 'ul'

    this

  renderItem: (model) ->
    item_view = new ItemView {model}
    @$list.append item_view.render().el
