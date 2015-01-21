module.exports = class IndicatorView extends Backbone.View

  template: require './templates/indicator'

  render: ->
    @$el.html @template()
    @$('[data-uk-margin]').ukMargin()

    this
