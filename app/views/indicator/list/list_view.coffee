ItemView = require './item_view'

module.exports = class IndicatorListView extends Backbone.View

  template: require './templates/list'

  initialize: ->
    @listenTo @collection, 'add', @renderItem
    @listenTo @collection, 'reset', @renderItems
  render: ->
    @$el.html @template()
    @$list = @$ 'ul'

    this

  renderItem: (model) ->
    item_view = new ItemView {model}
    @$list.append item_view.render().el

  renderItems: ->
    @collection.each @renderItem, this
