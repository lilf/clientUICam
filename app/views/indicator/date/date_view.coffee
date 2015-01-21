ItemView = require './item_view'

module.exports = class IndicatorDateView extends Backbone.View

  template: require './templates/date'

  initialize: ->
    @listenTo @collection, 'add', @renderItem
    @listenTo @collection, 'reset', @renderItems

  render: ->
    @$el.html @template()
    @$list = @$ '.uk-button-group'
    $.UIkit.buttonRadio @$list

    this

  renderItem: (model) ->
    item_view = new ItemView {model}
    @$list.append item_view.render().el

  renderItems: ->
    @$list.toggleClass 'only-one-button', @collection.length is 1
    @collection.each @renderItem, this
