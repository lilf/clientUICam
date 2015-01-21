module.exports = class LinkView extends Backbone.View

  template: require './templates/link'

  tagName: 'span'

  id: -> @model.cid

  events:
    'click': 'active'

  initialize: ->
    @listenTo @model, 'model:active', @active

  render: ->
    @$el.html @template @model.toJSON()

    this

  active: ->
    @$el
    .addClass 'uk-active'
    .siblings '.uk-active'
    .removeClass 'uk-active'

