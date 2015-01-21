module.exports = class NewstyleView extends Backbone.View

  template: require './templates/newstyle'

  render: ->
    @$el.html @template()

    this
