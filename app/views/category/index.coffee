CategoryView = require './category_view'

module.exports = class CategoryNode extends Backbone.Node

  requires:
    categories: 'categories'
    bigs: 'bigs'

  initialize: ->
    @category_view = new CategoryView
    $('#main_view').html @category_view.render().el

  ready: (params) ->
    [big_id, category_id] = params
    @bigs.trigger 'active_id', big_id
    @categories.trigger 'active_id', category_id

  restart: (params) ->
    [big_id, category_id] = params
    @bigs.trigger 'active_id', big_id
    @categories.trigger 'active_id', category_id
