config = require 'config'

class Method extends Backbone.Model

  idAttribute: '_id'

module.exports = class Methods extends Backbone.Collection

  model: Method

  url: ->
    config.api.baseUrl + '/methods'
