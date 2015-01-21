omitColumnsForTable = [ '_id', 'date', 'dateType', 'dateString', 'modeGroup', 'modeGroupString', 'modeGroupLength', 'modeType']
omitColumnsForChart = [ '_id', 'date', 'year', 'quarter', 'month', 'dateType', 'modeGroup', 'modeGroupString', 'modeGroupLength', 'modeType']

module.exports = class BigModes

  _.extend BigModes::, Backbone.Events

  constructor:  ->
    @initialize.apply this, arguments

  initialize: ->
    @on 'bigModes:set:mode', @setMode
    @on 'bigModes:set:date', @setDate
    @on 'bigModes:set:filter', @setFilter
    @on 'bigModes:set:method', @setMethod

  setMode: (modeName) ->
    mode = _.findWhere @modes, name: modeName
    active = _.findWhere @modes, selected: true
    active.selected = false
    mode.selected = true
    @getDates()
    @getFilters()
    @getMethods()
    @draw()
    @getChartOption()
    @getTableOption()
    @getInfo()

  setDate: (dateName) ->
    date = _.findWhere @dates, name: dateName
    active = _.findWhere @dates, selected: true
    active.selected = false
    date.selected = true
    @getFilters()
    @getMethods()
    @draw()
    @getChartOption()
    @getTableOption()
    @getInfo()

  setFilter: (filterName) ->

  setMethod: (methodName) ->

  reset: (@bigModes) ->
    # console.log 'I am listenling------------------------------------------------------'
    # console.log @bigModes
    @getModes()
    @getDates()
    @getFilters()
    @getMethods()
    @draw()
    @getChartOption()
    @getTableOption()
    @getInfo()

  getModes: ->
    results = @_getModes()
    @trigger 'bigModes:reset:modes', results

  getDates: ->
    results = @_getDates()
    @trigger 'bigModes:reset:dates', results

  getFilters: ->
    results = @_getFilters()
    @trigger 'bigModes:reset:filters', results

  getMethods: ->
    results = @_getMethods()
    @trigger 'bigModes:reset:methods', results

  draw: ->
    results = @_getBigMode()
    @trigger 'bigModes:draw:bigMode', results

  getChartOption: ->
    results = @_getChartOption()
    @trigger 'bigModes:chart:option', results

  getTableOption: ->
    results = @_getTableOption()
    @trigger 'bigModes:table:option', results

  getInfo: ->
    @_getInfo (results) => @trigger 'bigModes:info', results

  _getInfo: (callback) ->
    return false unless @bigMode
    { indicator, methods } = @bigMode
    # console.log @bigMode
    indicator.once 'latest', (latest) =>
      dateLatest = latest.date
      valueLatest = latest.value
      valueOldest = latest.rawdata_oldest.value
      previousPeriodDifference = latest.gap
      previousPeriodVariance = latest.gapPercent
      sexRatio = if latest.mValue then (latest.mValue / latest.fValue * 100).toFixed 1 else null
      minDate = latest.rawdata_oldest.date
      maxDate = latest.rawdata.date
      isF = if latest.rawdata.gender then true else false
      oldest_time = moment(minDate, 'YYYYMMDD')
      newest_time = moment(maxDate, 'YYYYMMDD')
      dateType = latest.rawdata.dateType
      _dateType = if dateType is 'quarter' then 'year' else dateType
      times = newest_time.diff oldest_time, _dateType
      times = times * 3 if dateType if 'quarter'
      _averageChange = (Math.pow(latest.rawdata.value / valueOldest, 1 / times) - 1)  * 100
      if _.isNaN _averageChange
        averageChange = null
      else
        averageChange = _averageChange.toFixed(2) + '%'
        averageChange = if _averageChange > 0 then '+' + averageChange else averageChange

      callback { dateType, isF, dateLatest, valueLatest, previousPeriodVariance, previousPeriodDifference, sexRatio, minDate, maxDate, averageChange}


    indicator.fetLatestInfo()

      # dateLatest =
      # valueLatest
      # previousPeriodVariance
      # previousPeriodDifference
      # sexRatio
      # minDate
      # maxDate
      # averageChange
      # average
      # minValue
      # minValueDate
      # maxVlue
      # maxVlueDate

  _getModes: ->
    @modes = _.chain @bigModes
      .pluck 'name'
      .uniq()
      .map (name, i) -> {name, selected: (if i is 0 then true else false)}
      .value()

  _getDefaultMode: ->
    mode = _.findWhere @modes, selected: true
    mode and mode.name

  _getDates: ->
    modeName = @_getDefaultMode()
    @dates = _.chain @bigModes
      .filter (bigMode) -> bigMode.name is modeName
      .pluck 'dateType'
      .uniq()
      .map (name, i) -> {name, selected: (if i is 0 then true else false)}
      .value()

  _getDefaultDate: ->
    date = _.findWhere @dates, selected: true
    date and date.name

  _getBigMode: ->
    modeName = @_getDefaultMode()
    dateName = @_getDefaultDate()

    @bigMode = _.findWhere @bigModes, name: modeName, dateType: dateName

  _getFilters: ->
    modeName = @_getDefaultMode()
    dateName = @_getDefaultDate()

    bigMode = _.findWhere @bigModes, name: modeName, dateType: dateName
    @filters = if bigMode then bigMode.columns else []

  _getMethods: ->
    modeName = @_getDefaultMode()
    dateName = @_getDefaultDate()
    bigMode = _.findWhere @bigModes, name: modeName, dateType: dateName
    @methods = if bigMode then bigMode.methods else []

  _getChartOption: ->
    return rawdatas: [] unless @bigMode
    rawdatas = _.chain @bigMode.rawdatas
      .map (rawdata) ->
        rawdata = _.omit rawdata, omitColumnsForChart...
        rawdata.date = moment(rawdata.date, 'YYYYMMDD').format('YYYY-MM-DD')
        rawdata
      .value()
    modeType = @bigMode.modeType
    { rawdatas, modeType }

  _getTableOption: ->
    return [] unless @bigMode
    _.chain @bigMode.rawdatas
      .map (rawdata) -> _.omit rawdata, omitColumnsForTable...
      .value()
