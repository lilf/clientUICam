LinkView = require './link_view'
AreaView = require './area_view'

module.exports = class CategoryBigView extends Backbone.View

  template: require './templates/big'

  initialize: ->
    @listenTo @collection, 'add', @addLink
    @listenTo @collection, 'reset', @addLinks

  render: ->
    @$el.html @template()
    @$list = @$('ul[data-uk-switcher]')
    @$area = @$('ul.uk-switcher')

    this

  addLink: (model) ->
    link_view = new LinkView {model}
    @$list.append link_view.render().el

    area_view = new AreaView {model}
    @$area.append area_view.render().el

  addLinks: ->
    @collection.each @addLink, this
