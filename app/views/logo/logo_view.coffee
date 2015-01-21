module.exports = class LogoView extends Backbone.View

  template: require './templates/logo'

  className: 'uk-text-center'

  render: ->
    @$el.html @template()

    this
