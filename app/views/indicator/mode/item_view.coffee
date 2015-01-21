module.exports = class ItemView extends Backbone.View

  template: require './templates/item'

  tagName: 'button'

  className: ->
    selected = @model.get 'selected'
    if selected then 'uk-button uk-active' else 'uk-button'

  events:
    'click': 'click'

  initialize: ->
    @listenTo @model, 'remove', @remove

  render: ->
    @$el.html @template @model.toJSON()

    this

  click: ->
    @model.trigger 'active', @model.get 'name'
