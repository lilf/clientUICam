config = require 'config'

class Category extends Backbone.Model

  idAttribute: '_id'

module.exports = class Categories extends Backbone.Collection

  model: Category

  url: ->
    config.api.baseUrl + '/categories'

  comparator: 'order'

  fetch: (options = {}) ->
    options.data ?= {}
    options.data.active = true
    super options

  sortByCid: ->
    collection = this
    (itemA, itemB) ->
          a = itemA.getAttribute 'id'
          b = itemB.getAttribute 'id'
          x = collection.get a
          y = collection.get b
          m = collection.indexOf x
          n = collection.indexOf y
          m - n
