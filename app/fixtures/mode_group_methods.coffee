_sexRatio = (m, f) ->
  +((m / f * 100).toFixed 1)

_div = (m, f) ->
  +((m / f).toFixed 2)

_percent = (m, f) ->
  +((m / f * 100).toFixed 2)

_toPercent = (number) ->
  +((number * 100).toFixed 2)

exports.methods = ers.analyzeMethods =
  sexRatio: (rawdatas, x, y) ->
    _.chain rawdatas
      .groupBy x
      .map (values, key) ->
        { M, F } = _.groupBy values, 'gender'
        value = _sexRatio M[0][y], F[0][y]
        [key, value]
      .object()
      .value()

  average: (rawdatas, l, y) ->
    _.chain rawdatas
      .groupBy l
      .map (values, key) ->
        up = _.chain values
          .pluck y
          .reduce ((memo, num) -> memo + num), 0
          .value()
        down = values.length
        value = _div up, down
        [key, value]
      .object()
      .value()

  averageChange: (rawdatas, l, y) ->
    _.chain rawdatas
      .groupBy l
      .map (values, key) ->
        oldest = _.first values
        newest = _.last values
        oldest_time = moment(oldest.date, 'YYYYMMDD')
        newest_time = moment(newest.date, 'YYYYMMDD')
        dateType = newest.dateType
        times = newest_time.diff oldest_time, dateType
        value = Math.pow newest[y] / oldest[y], 1 / times
        value = _toPercent value - 1
        [key, value]
      .object()
      .value()

  maximum: (rawdatas, l, y) ->
    _.chain rawdatas
      .groupBy l
      .map (values, key) ->
        value = _.chain values
          .pluck y
          .max()
          .value()
        [key, value]
      .object()
      .value()

  minimum: (rawdatas, l, y) ->
    _.chain rawdatas
      .groupBy l
      .map (values, key) ->
        value = _.chain values
          .pluck y
          .min()
          .value()
        [key, value]
      .object()
      .value()

  previousPeriodVariance: (rawdatas, l, y) ->
    _.chain rawdatas
      .groupBy l
      .map (values, key) ->
        results = _.chain values
          .pluck y
          .value()

        value = for next, i in results
          previous = values[ i - 1]?[y]
          _percent (next - previous), previous
        [key, value]
      .object()
      .value()

  previousPeriodDifference: (rawdatas, l, y) ->
    _.chain rawdatas
      .groupBy l
      .map (values, key) ->
        results = _.chain values
          .pluck y
          .value()

        value = for next, i in results
          previous = values[ i - 1]?[y]
          next - previous

        [key, value]
      .object()
      .value()

  samePeriodVariance: (rawdatas, x, y) ->

  samePeriodDifference: (rawdatas, x, y) ->

exports.method_modes = [
  name: '趨勢'
  modeType: 'date-value'
  methods: ['average', 'maximum', 'minimum', 'previousPeriodVariance', 'previousPeriodDifference', 'averageChange']
,
  name: '趨勢'
  modeType: 'date-gender-value'
  methods: ['sexRatio', 'average', 'maximum', 'minimum', 'previousPeriodVariance', 'previousPeriodDifference', 'averageChange']
,
  name: '年齡'
  modeType: 'date-age-value'
  methods: ['average', 'maximum', 'minimum']
,
  name: '年齡'
  modeType: 'date-age-gender-value'
  methods: ['sexRatio', 'average', 'maximum', 'minimum']
]

exports.getMethodsByModeType = (modeType) ->
  method = _.findWhere @method_modes, { modeType }
  { name, methods } = method

  methods = _.map methods, (name) =>
    method = @methods[name]
    result = null
    { name, method, result }

  { name, methods }
