module.exports = class CategoryView extends Backbone.View

  template: require './templates/category'

  render: ->
    @$el.html @template()
    @$el.ukMargin()

    this
