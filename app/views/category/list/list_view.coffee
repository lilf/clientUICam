ItemView = require './item_view'

module.exports = class CategoryListView extends Backbone.View

  template: require './templates/list'

  initialize: ->
    @listenTo @collection, 'add', @renderItem
    @listenTo @collection, 'sort', @sortItem
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

  sortItem: (collection) ->
    $items = @$list.children()
    $items.sort collection.sortByCid()

    $items.detach().appendTo @$list

  setClassName: (big_id = 1) ->
    # for styling
    @$list.attr 'id', 'big' + big_id
