module.exports = class ProfileView extends Backbone.View

  template: require './templates/profile'

  render: ->
    @$el.html @template()

    this
