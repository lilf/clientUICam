module.exports = (chart_options) ->
  { timeline, option, data, date, xAxis, legend, yAxis, titleFormatter, seriesOption} = chart_options

  titleFormatter ?= (d) -> text: d

  return chart_options unless seriesOption?.type and timeline?.data and option?.legend?.data
  return chart_options if _.isEmpty(date) or _.isEmpty(legend) or _.isEmpty(yAxis)

  options = _.chain timeline.data
    .map (d, i) ->

      _option = if i is 0 then option else {}
      _option.title = titleFormatter d, chart_options

      dateCondition = {}
      dateCondition[date] = d

      series = _.where data, dateCondition


      # for chart type bar or line
      if xAxis and option.xAxis?[0]?.data
        _option.series = _.chain option.legend.data
          .map (dd) ->
            legendCondition = {}
            legendCondition[legend] = dd
            temp_data = _.chain series
              .where legendCondition
              .indexBy xAxis
              .value()

            _data = _.map option.xAxis[0].data, (ddd) -> if temp_data[ddd] and temp_data[ddd][yAxis] then temp_data[ddd][yAxis] else '-'

            _series = _.extend {}, seriesOption, name: dd, data: _data

            _series
          # .value()

        _option.series = _option.series.value()
      else
        # for chart type pie
        _data = _.chain option.legend.data
          .map (dd) ->
            legendCondition = {}
            legendCondition[legend] = dd
            rawdata = _.findWhere series, legendCondition
            name: dd
            value: rawdata[yAxis] or '-'
          .value()

        _option.series = [_.extend {}, seriesOption, name: xAxis, data: _data]


      _option

    .value()

  timeline: timeline
  options: options
