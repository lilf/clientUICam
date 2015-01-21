module.exports = class LinkView extends Backbone.View

  template: require './templates/link'

  tagName: 'li'

  # className: 'uk-width-1-3'

  initialize: ->
    @listenTo @model, 'model:active', @active

  events:
    'click': 'click'

  render: ->
    @$el.html @template @model.toJSON()

    this

  active: ->
    @$el
    .addClass 'uk-active'
    .siblings '.uk-active'
    .removeClass 'uk-active'

  click: ->
    @model.trigger 'router:to:category', @model.get '_id'
