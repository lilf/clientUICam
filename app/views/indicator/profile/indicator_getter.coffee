toOmitAttrs = ['__v', '_id', 'active']
IMRS = require 'models/indicator_mode_rawdata_sources'
Indicators = require 'models/indicators'
Modes = require 'models/modes'
Rawdatas = require 'models/rawdatas'
Sources = require 'models/sources'


# fork from methods.coffee
modeGroup = (rawdatas) ->
  _.groupBy rawdatas, (rawdata) ->
    rawdata = _.omit rawdata, toOmitAttrs...
    _.keys(rawdata).sort().join '_'

omitFunc = (x) -> if x.omit then x.omit toOmitAttrs... else _.omit x, toOmitAttrs...

getSourcesText = (sources) ->
  _.chain sources
    .map (source) ->
      if source.name is source.publisher
        source.name
      else
        source.publisher + '-' + source.name
    .value()
    .join('; ')

module.exports = (query) -> # {_id: indicator_id} or {name: indicator_name}
  return if _.isEmpty query
  imrs = new IMRS
  indicators = new Indicators
  modes = new Modes
  rawdatas = new Rawdatas
  sources = new Sources

  _.extend {}, Backbone.Events,

    fetch: ->
      $
      .when @fetchIndicator query
      .then @fetchIMRS()
      .then @fetchOther()
      .then @toJSON()
      .then @groupBy()

    groupBy: -> (all) ->
      groupByMode = modeGroup rawdatas.toJSON()

      for key, values of groupByMode
        rawdata_ids = _.pluck values, '_id'
        _sources = _.chain imrs.toJSON()
          .filter (_imrs) -> _.contains rawdata_ids, _imrs.rawdata_id
          .pluck 'source_id'
          .uniq()
          .map (source_id) -> sources.get(source_id).omit toOmitAttrs...
          .value()

        _sources_text = getSourcesText _sources

        _values = _.map values, omitFunc

        all[key] =
          rawdatas: _values
          sources: _sources
          sources_text: _sources_text

      all.modes = all.modes.map omitFunc
      all.rawdatas = all.rawdatas.map omitFunc
      all.sources = all.sources.map omitFunc
      all.sources_text = getSourcesText all.sources

      $.when all

    toJSON: -> ->
      indicatorsJSON = indicators.toJSON()
      indicator = if indicatorsJSON.length then indicatorsJSON[0] else null
      indicator = _.omit indicator, toOmitAttrs... if indicator

      $.when
        indicator: indicator
        modes: modes
        rawdatas: rawdatas
        sources: sources

    fetchIndicator: (query = {}) ->
      indicators.fetch data: query

    fetchIMRS: -> ->
      return $.when() unless indicators.length
      indicator = indicators.first()
      imrs.fetch data: indicator_id: indicator.id

    fetchOther: -> =>
      $.when @fetchModes(), @fetchRawdatas(), @fetchSources()

    fetchModes: ->
      mode_ids = @getIds 'mode_id'
      # console.log 'mode_ids'
      # console.log 'mode_ids', mode_ids.length, @imrs.length
      @fetchActivedByIds modes, mode_ids

    fetchSources: ->
      source_ids = @getIds 'source_id'
      # console.log 'source_ids', source_ids.length, @imrs.length
      @fetchActivedByIds sources, source_ids

    fetchRawdatas: ->
      rawdata_ids = @getIds 'rawdata_id'
      # console.log 'rawdata_ids', rawdata_ids.length, @imrs.length
      @fetchActivedByIds rawdatas, rawdata_ids

    fetchActivedByIds: (collection, _ids) ->
      return $.when [] if _.isEmpty _ids
      url = collection.url() + '/search'
      $
      .post url,
        where:
          active: true
        in:
          _id: _ids
      .done (data) -> collection.add data

    getIds: (name_id) ->
      # console.log imrs, name_id
      _.keys imrs.groupBy name_id
