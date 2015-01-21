module.exports = class IndicatorFilterView extends Backbone.View

  template: require './templates/filter'

  render: ->
    @$el.html @template()

    this