config = require 'config'

class ColumnMode extends Backbone.Model

  idAttribute: '_id'

module.exports = class ColumnModes extends Backbone.Collection

  model: ColumnMode

  url: ->
    config.api.baseUrl + '/column_modes'
