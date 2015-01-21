module.exports = class AboutusView extends Backbone.View

  template: require './templates/aboutus'

  className: 'aboutus'

  render: ->
    @$el.html @template()

    this