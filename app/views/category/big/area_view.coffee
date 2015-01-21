module.exports = class AreaView extends Backbone.View

  template: require './templates/area'

  tagName: 'li'

  initialize: ->
    @listenTo @model, 'model:active', @active

  render: ->
    @$el.html @template @model.toJSON()
    @$el.addClass 'uk-active' if @model.get 'active'

    this

  active: ->
    @$el
    .addClass 'uk-active'
    .siblings '.uk-active'
    .removeClass 'uk-active'
