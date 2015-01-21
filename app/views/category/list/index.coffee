CategoryListView = require './list_view'

module.exports = class CategoryListNode extends Backbone.Node

  requires:
    categories: 'categories'
    bigs: 'bigs'
    router: 'router'

  initialize: ->
    @collection = new Backbone.Collection
    @list_view = new CategoryListView { @collection }
    $('#category_list_view').html @list_view.render().el

  ready: ->
    @listenTo @collection, 'router:to:category', @routerToCategory
    @listenTo @categories, 'active_id', @active

  active: (active_id) ->
    @when 'bigs:active_id', 'categories:active_id', 'categories:sync', 'bigs:sync', @reAdd

  activeCategory: (category_id) ->
    model = @collection.findWhere _id: category_id
    unless model
      model = @collection.first()
      @categories.trigger 'active_id', model.get '_id'
    model.trigger 'model:active'

  reAdd: (big_id, category_id) ->
    @list_view.setClassName big_id
    @collection.remove @collection.models
    big = @bigs.findWhere _id: big_id
    big = @bigs.first() unless big
    categories = @filterByBig big, @categories
    @collection.reset categories
    @activeCategory category_id

  routerToCategory: (category_id) ->
    big_id = @getBigIdFromCategoryId category_id
    @router.toCategory big_id, category_id

  getBigIdFromCategoryId: (category_id) ->
    category = @categories.get category_id
    big = @bigs.find (big) -> _.contains big.get('children'), category.get('name')
    big_id = big.get '_id'

  filterByBig: (big, categories) ->
    names = big.get 'children'
    _.chain names
      .map (name) -> categories.findWhere { name }
      .compact()
      .map (category) -> category.toJSON()
      .value()

