module.exports = class IndicatorMethodView extends Backbone.View

  template: require './templates/method'

  render: ->
    @$el.html @template()

    this