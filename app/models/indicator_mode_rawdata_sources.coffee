config = require 'config'

class IndicatorModeRawdataSource extends Backbone.Model

  idAttribute: '_id'

module.exports = class IndicatorModeRawdataSources extends Backbone.Collection

  model: IndicatorModeRawdataSource

  url: ->
    config.api.baseUrl + '/indicator_mode_rawdata_sources'
