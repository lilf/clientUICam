module.exports = class HomeView extends Backbone.View

  template: require './templates/home'

  events:
  	'click .uk-width-1-3': 'bigCategory'

  render: ->
    @$el.html @template()

    this

  bigCategory: (e) ->
  	i = @$('.cam-index-indicator-category-box .uk-width-1-3').index e.currentTarget
  	i++
  	window.location.hash = '#category/' + i