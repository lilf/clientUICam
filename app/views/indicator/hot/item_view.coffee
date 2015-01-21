module.exports = class ItemView extends Backbone.View

  template: require './templates/item'

  tagName: 'li'

  # className: 'uk-margin-small-top'

  events:
    'click a': 'click'

  render: ->
    @$el.html @template @model.toJSON()

    this

  click: (e) ->
    e.preventDefault()
    @model.trigger 'indicator_id', @model.get '_id'
