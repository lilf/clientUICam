CategoryBigView = require './big_view'
Links = require 'models/links'
links = require './links'

module.exports = class CategoryBigNode extends Backbone.Node

  requires:
    bigs: 'bigs'
    categories: 'categories'
    router: 'router'

  initialize: ->
    @collection = new Backbone.Collection
    @big_view = new CategoryBigView { @collection }
    $('#big_category_view').html @big_view.render().el

  ready: ->
    @listenTo @collection, 'router:to:category', @routerToCategory
    @listenToOnce @bigs, 'active_id', @bigIdActived

  bigIdActived: (active_id) ->
    @when 'bigs:active_id', 'bigs:sync', @reAdd

  activeBig: (active_id) ->
    model = @collection.findWhere _id: active_id
    unless model
      model = @collection.first()
    model.trigger 'model:active'

  reAdd: (active_id) ->
    @collection.reset @bigs.toJSON()
    @activeBig active_id

  routerToCategory: (big_id) ->
    @router.toCategory big_id
