module.exports = class IndicatorAnalyzeView extends Backbone.View

  template: require './templates/analyze'

  render: ->
    @$el.html @template()

    this
