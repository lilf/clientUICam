config = require 'config'

IMRS = require 'models/indicator_mode_rawdata_sources'
Modes = require 'models/modes'
Rawdatas = require 'models/rawdatas'
Sources = require 'models/sources'
modeGroup_methods = require 'fixtures/mode_group_methods'
indicators_with_no_data = require 'fixtures/indicators_with_no_data'

class Indicator extends Backbone.Model

  idAttribute: '_id'

  parse: (data) ->
    names = data.name.split '/'
    data.searchName = data.name
    data.name = names[0]
    data.hasData = if _.contains indicators_with_no_data, data.name then false else true

    data

  initialize: ->
    @imrs = new IMRS
    @modes = new Modes
    @rawdatas = new Rawdatas
    @sources = new Sources

  fetchAll: ->
    $
    .when @_fetchAll()
    .then => @fillAll()

  fetLatestInfo: ->
    $
    .when @_fetchAll()
    .then => @_fetLatestInfo()

  fillAll: ->
    self = this
    rawdatasJSON = @rawdatas.toJSON()

    bigModes = _.chain rawdatasJSON
      .groupBy 'modeType'
      .map (rawdatas, modeType) ->
        _.chain rawdatas
          .groupBy 'dateType'
          .map (rawdatasByDate, dateType) ->
            { name, methods } = self.getNameAndMethodsFromModeType modeType
            sources = self.getSourcesByRawdatas rawdatasByDate
            columns = self.getColumnsByRawdatas rawdatasByDate, modeType
            _columns = _.pluck columns, 'name'
            _columns.unshift 'date'
            rawdatasByDate = _.sortBy2 rawdatasByDate, _columns...
            name: name
            modeType: modeType
            dateType: dateType
            rawdatas: rawdatasByDate
            sources: sources
            columns: columns
            methods: methods
            indicator: self
          .value()
      .flatten()
      .value()

    @trigger 'bigModes', bigModes
    # console.log window.bigModes = bigModes
    # one = bigModes[0]
    # console.log 'rawdatas'
    # console.log one.rawdatas
    # console.log 'sexRatio'
    # console.log ers.analyzeMethods.sexRatio(one.rawdatas, 'date', 'value')
    # console.log 'average'
    # console.log ers.analyzeMethods.average(one.rawdatas, 'gender', 'value')
    # console.log 'averageChange'
    # console.log ers.analyzeMethods.averageChange(one.rawdatas, 'gender', 'value')
    # console.log 'maximum'
    # console.log ers.analyzeMethods.maximum(one.rawdatas, 'gender', 'value')
    # console.log 'minimum'
    # console.log ers.analyzeMethods.minimum(one.rawdatas, 'gender', 'value')
    # console.log 'previousPeriodVariance'
    # console.log ers.analyzeMethods.previousPeriodVariance(one.rawdatas, 'gender', 'value')
    # console.log 'previousPeriodDifference'
    # console.log ers.analyzeMethods.previousPeriodDifference(one.rawdatas, 'gender', 'value')


  _fetLatestInfo: ->
    rawdatasJSON = @rawdatas.toJSON()
    return @trigger 'notFound' unless rawdatasJSON.length
    rawdatas = _.groupBy rawdatasJSON, 'modeGroupLength'
    leastKeys = _.chain(rawdatas).keys().min().value()
    rawdatas = rawdatas[leastKeys]

    _rawdatas = _.groupBy rawdatas, 'date'
    latest = _.chain(_rawdatas).keys().max().value()
    rawdatas = _rawdatas[latest]

    oldest = _.chain(_rawdatas).keys().min().value()
    rawdatas_oldest = _rawdatas[oldest]

    rawdatas = _.filter rawdatas, (rawdata) -> if rawdata.gender then rawdata.gender is 'F' else true

    rawdata = _.max rawdatas, (rawdata) -> rawdata.value


    sourceName = @getSourceFromRawdata rawdata._id
    labels = _.chain rawdata.modeGroup
      .map (column) -> name: column, label: rawdata[column]
      .reject (label) -> label.label is 'Total'
      .value()

    condition = if _.isEmpty rawdata.modeGroup then {} else _.pick rawdata, rawdata.modeGroup...
    # console.log 'condition', condition

    condition4 = _.extend {}, condition, dateType: rawdata.dateType, modeGroupString: rawdata.modeGroupString

    rawdatas_oldest = _.where rawdatasJSON, condition4

    _rawdatas_oldest = _.groupBy rawdatas_oldest, 'date'

    oldest = _.chain(_rawdatas_oldest).keys().min().value()
    rawdatas_oldest = _rawdatas[oldest]

    rawdatas_oldest = _.filter rawdatas_oldest, (rawdata) -> if rawdata.gender then rawdata.gender is 'F' else true

    rawdata_oldest = rawdatas_oldest[0]

    # find male value if rawdata.gender
    if rawdata.gender
      condition3 = _.extend {}, condition, {gender: 'M'},  date: rawdata.date, dateType: rawdata.dateType, modeGroupString: rawdata.modeGroupString
      conterpart = _.findWhere rawdatasJSON, condition3
      mValue = conterpart.value

    # find last value
    lastDate = moment(rawdata.date, 'YYYYMMDD').subtract(rawdata.dateType, 1).endOf(rawdata.dateType).format('YYYYMMDD')

    condition2 = _.extend {}, condition, date: lastDate, dateType: rawdata.dateType, modeGroupString: rawdata.modeGroupString
    # console.log 'condition2', condition2
    last_rawdata = _.findWhere rawdatasJSON, condition2
    # console.log 'Indicator', @get 'name'
    # console.log 'new', rawdata
    # console.log 'old', last_rawdata
    # console.log 'rawdatas', _.where rawdatasJSON, _.extend condition, dateType: rawdata.dateType, modeGroupString: rawdata.modeGroupString
    # console.log 'rawdatas toJSON', rawdatasJSON
    if last_rawdata
      lastValue = last_rawdata.value
      gap = rawdata.value - last_rawdata.value
      if /\./.test gap.toString()
        _gap = gap.toFixed 2
      else
        _gap = ers.numberWithCommas gap

      _gapPercent = gap / lastValue
      gapPercent = unless _.isNaN _gapPercent then (gap / lastValue * 100).toFixed(2) + '%' else false
      # direction = if gap > 0 then 'up' else 'down'
      direction = switch
        when gap > 0 then 'up'
        when gap is 0 then 'minus'
        when gap < 0 then 'down'
    else
      lastValue = '-'
      direction = '-'
      gap = '-'


    latest =
      rawdata: rawdata
      value: ers.numberWithCommas rawdata.value
      lastValue: ers.numberWithCommas lastValue
      gapPercent: if gap > 0 then '+' + gapPercent else gapPercent
      date: rawdata.date
      source: sourceName
      labels: labels
      gap: if gap > 0 then '+' + _gap else _gap
      direction: direction
      mValue: mValue
      fValue: rawdata.value
      rawdata_oldest: rawdata_oldest

    @trigger 'latest', latest

  getNameAndMethodsFromModeType: (modeType) ->
    modeGroup_methods.getMethodsByModeType modeType

  getColumnsByRawdatas: (rawdatas, modeGroupString) ->
    columns = modeGroupString.split '-'
    _.chain columns
      .reject (column) -> _.contains ['date', 'value'], column
      .map (column) =>
        values = _.chain(rawdatas).pluck(column).uniq().value()
        selected = if column is 'gender' then ['F'] else values

        name: column
        values: values
        selected: selected
      .value()


  getSourceFromRawdata: (rawdata_id) ->
    imrs = @imrs.findWhere { rawdata_id }
    return '' unless imrs
    source_id = imrs.get 'source_id'
    source = @sources.get source_id
    return unless source
    source = source.toJSON()
    if source.name is source.publisher
      source.name
    else
      source.publisher + '-' + source.name

  getSourcesByRawdatas: (rawdatas) ->
    _.chain rawdatas
      .map ((rawdata) -> @getSourceFromRawdata rawdata._id), this
      .uniq()
      .compact()
      .value()
      .join('; ')

  getModeFromRawdata: (rawdata_id) ->
    imrs = @imrs.findWhere { rawdata_id }
    return '' unless imrs
    mode_id = imrs.get 'mode_id'
    mode = @modes.get mode_id
    mode.get 'name'

  # real fetch function
  _fetchAll: ->
    @allSynced ?= $
    .when @fetchIMRS2()
    .then => $.when @fetchModes2(), @fetchRawdatas2(), @fetchSources2()

  fetchIMRS2: ->
    indicator_id = @id
    @imrs.fetch data: { indicator_id }

  fetchModes2: ->
    mode_ids = @getIds 'mode_id'
    # console.log 'mode_ids', mode_ids.length, @imrs.length
    @modes.fetchActivedByIds mode_ids

  fetchSources2: ->
    source_ids = @getIds 'source_id'
    # console.log 'source_ids', source_ids.length, @imrs.length
    @sources.fetchActivedByIds source_ids

  fetchRawdatas2: ->
    rawdata_ids = @getIds 'rawdata_id'
    # console.log 'rawdata_ids', rawdata_ids.length, @imrs.length
    @rawdatas.fetchActivedByIds rawdata_ids

  detail: ->
    latest = @rawdatas.getLatest()
    console.log latest

  fetchIMRS: ->
    if @imrs.length
      @imrs.trigger 'sync', @imrs
    else
      indicator_id = @id
      @imrs.fetch data: {indicator_id}

  fetchModes: ->
    if @modes.length
      @trigger 'modes', @modes
    else
      mode_ids = @getIds 'mode_id'
      @modes
      .fetchActivedByIds mode_ids
      .then => @trigger 'modes', @modes

  fetchRawdatas: ->
    if @rawdatas.length
      @rawdatas.trigger 'sync', @rawdatas
    else
      rawdata_ids = @getIds 'rawdata_id'
      @rawdatas
      .fetchActivedByIds rawdata_ids
      .then =>
        @rawdatas.trigger 'sync', @rawdatas
        @trigger 'rawdatas', @sources

  fetchSources: ->
    if @sources.length
      @trigger 'sources', @sources
    else
      source_ids = @getIds 'source_id'
      @sources
      .fetchActivedByIds source_ids
      .then =>
        @sources.trigger 'sync', @sources
        @trigger 'sources', @sources

  fetchOther: ->
    @fetchModes()
    @fetchSources()
    @fetchRawdatas()

  filterByModeId: (mode_id) ->
    @mode_id = mode_id
    imrs = @imrs.where { mode_id }
    $
    .when @smartGroup(imrs, 'source_id', @sources), @smartGroup(imrs, 'rawdata_id', @rawdatas)
    .then (sources, rawdatas) => @trigger 'change:mode', rawdatas, sources, this.toJSON()

  smartGroup: (imrs, name_id, collection) ->
    defer = $.Deferred()
    if collection.length
      result = @group imrs, name_id, collection
      defer.resolve result
    else
      @listenToOnce collection, 'sync', =>
        result = @group imrs, name_id, collection
        defer.resolve result

    defer.promise()

  group: (imrs, name_id, collection) ->
    _.chain imrs
      .groupBy (_imrs_) -> _imrs_.get name_id
      .keys()
      .map (_id) -> collection.get(_id).omit '_id', '__v', 'active'
      .value()

  getIds: (name_id) ->
    _.keys @imrs.groupBy name_id


module.exports = class Indicators extends Backbone.Collection

  model: Indicator

  url: ->
    config.api.baseUrl + '/indicators'

  fetch: (options = {}) ->
    options.data ?= {}
    options.data.active = true
    super options

  comparator: 'order'
