config = require 'config'

class Rawdata extends Backbone.Model

  idAttribute: '_id'

module.exports = class Rawdatas extends Backbone.Collection

  model: Rawdata

  url: ->
    config.api.baseUrl + '/rawdatas'

  comparator: 'date'

  getNew: ->
    models = @filter (model) -> model.isNew()
    models[0]

  getOld: ->
    models = @reject (model) -> model.isNew()
    models[0]

  fetch: (options = {}) ->
    options.data ?= {}
    options.data.active = true
    super options

  fetchActivedById: (_id) ->
    $.get @url(), {_id, active: true}

  fetchActivedByIds: (_ids) ->
    # _.map _ids, @fetchActivedById, this
    @fetchActivedByIn _ids

  fetchActivedByIn: (_ids) ->
    return $.when [] if _.isEmpty _ids
    url = @url() + '/search'
    $
    .post url,
      where:
        active: true
      in:
        _id: _ids
    .done (data) =>
      data = _.map data, @parseData, this
      data = @sortByDateAndModeGroupLength data
      @add data

  parseData: (data) ->
    data = _.omit data, 'active', '__v'
    data.modeGroup = @detectModeGroup data
    data.modeGroupString = data.modeGroup.join '-'
    data.modeType = @getMode data
    data.modeGroupLength = data.modeGroup.length
    data.dateType = @detectDateType data
    data.date = @getDate data
    data.dateString = @getDateString data.dateType, data
    data

  getDateString: (dateType, data) ->
    switch dateType
      when 'year' then data.year
      when 'quarter' then data.year + jade.t('quarter' + data.quarter)
      when 'month' then data.year + jade.t('month' + data.month)

  getMode: (data) ->
    modeGroup = data.modeGroup.slice()
    modeGroup.unshift 'date'
    modeGroup.push 'value'
    modeGroup.join '-'

  detectModeGroup: (data) ->
    data = _.omit data, 'year', 'quarter', 'month', 'value', '_id'
    keys = _.keys data
    keys.sort()

  getDate: (data) ->
    m = moment()
    { year, quarter, month } = _.pick data, 'year', 'quarter', 'month'
    year = year.split('/')[1] if /\//.test year
    year = year.split('-')[1] if /-/.test year

    return m.year(year).quarter(quarter).endOf('quarter').format('YYYYMMDD') if year and quarter
    return m.year(year).month(month - 1).endOf('month').format('YYYYMMDD') if year and month
    return m.year(year).endOf('year').format('YYYYMMDD') if year

  _getMonthFromQuarter: (num) ->
    switch num
      when 1 then 3
      when 2 then 6
      when 3 then 9
      when 4 then 12


  detectDateType: (data) ->
    return 'month' if data.month
    return 'quarter' if data.quarter
    return 'year' if data.year
    false

  sortByDateAndModeGroupLength: (datas) ->
    _.sortBy2 datas, 'date', 'modeGroupLength'

