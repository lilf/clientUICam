config = require 'config'

class MethodMode extends Backbone.Model

  idAttribute: '_id'

module.exports = class MethodModes extends Backbone.Collection

  model: MethodMode

  url: ->
    config.api.baseUrl + '/method_modes'
