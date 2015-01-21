config = require 'config'

class Log extends Backbone.Model

  idAttribute: '_id'

module.exports = class Logs extends Backbone.Collection

  model: Log

  url: ->
    config.api.baseUrl + '/logs'
