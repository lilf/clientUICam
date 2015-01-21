module.exports = class LayoutView extends Backbone.View

  template: require './templates/layout'

  render: ->
    @$el.html @template()

    this
