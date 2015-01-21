toOmitAttrs = ['__v', '_id', 'active']
config = require 'config'

imrsUrl = config.api.baseUrl + '/imrs'

indicatorUrl = config.api.baseUrl + '/indicators'

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

getAll = (query) -> # {indicator_id: indicator_id}
  return if _.isEmpty query
  defer = $.Deferred()

  $
  .get imrsUrl, query
  .then (data) ->
    { indicators, modes, rawdatas, sources, imrs } = data
    all = {}
    groupByMode = modeGroup rawdatas

    for key, values of groupByMode
      rawdata_ids = _.pluck values, '_id'
      _sources = _.chain imrs
        .filter (_imrs) -> _.contains rawdata_ids, _imrs.rawdata_id
        .pluck 'source_id'
        .uniq()
        .map (source_id) -> _.chain(sources).findWhere(_id: source_id).omit(toOmitAttrs...).value()
        .value()

      _sources_text = getSourcesText _sources

      _values = _.map values, omitFunc

      all[key] =
        rawdatas: _values
        sources: _sources
        sources_text: _sources_text

    all.indicator = indicators[0]
    all.modes = _.map modes, omitFunc
    all.rawdatas = _.map rawdatas, omitFunc
    all.sources = _.map sources, omitFunc
    all.sources_text = getSourcesText all.sources

    defer.resolve all

  defer.promise()

module.exports = (query) ->
  $.get indicatorUrl, query
  .then (indicators) ->
    return $.when() unless indicators.length
    indicator = indicators[0]
    getAll indicator_id: indicator._id
