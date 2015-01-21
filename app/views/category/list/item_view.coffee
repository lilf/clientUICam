module.exports = class ItemView extends Backbone.View

  template: require './templates/item'

  tagName: 'li'

  id: -> @model.cid

  # className: 'uk-margin-small-bottom'

  events:
    'click .category-item': 'chooseAcategory'

  initialize: ->
    @listenTo @model, 'remove', @remove
    @listenTo @model, 'model:active', @active

  render: ->
    @$el.html @template @model.toJSON()

    this

  active: ->
    @$el
    .addClass 'uk-active'
    .siblings '.uk-active'
    .removeClass 'uk-active'

  chooseAcategory: (e) ->
    e.preventDefault()
    @model.trigger 'router:to:category', @model.get '_id'
