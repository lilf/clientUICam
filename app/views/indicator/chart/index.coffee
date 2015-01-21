IndicatorChartView = require './chart_view'
transformerOut = require './transformer'

module.exports = class IndicatorChartNode extends Backbone.Node

  requires:
    indicators: 'indicators'
    bigModes: 'bigModes'

  initialize: ->
    @chart_view = new IndicatorChartView
    $('#indicator_chart_view').html @chart_view.render().el

  ready: ->
    @chart_view.initChart()
    @listenTo @chart_view, 'chart:data_zoom', @dataZoom
    @listenTo @chart_view, 'chart:legend_selected', @legendSelected
    @listenTo @indicators, 'add:item', @addItem
    @listenTo @indicators, 'change:mode', @changeMode

    @listenTo @bigModes, 'bigModes:chart:option', @drawByOption


  drawByOption: (params) ->
    { rawdatas, modeType } = params
    transformer = transformerOut()
    if rawdatas.length
    # console.log transformer
      option = transformer modeType, rawdatas
    else
      option = false
    # console.log JSON.stringify option
    @chart_view.setOption option
    # @chart_view.drawByData rawdatas, sources, indicator

  addItem: (@indicator_id) ->
    @chart_view.start()

  changeMode: (rawdatas, sources, indicator) ->
    @rawdatas = rawdatas
    @chart_view.end()
    @chart_view.drawByData rawdatas, sources, indicator

  dataZoom: (e) =>
    {legend, dataZoom} = @chart_view.chart.component
    return unless legend and dataZoom
    @rawdataConnect legend._selectedMap, dataZoom._zoom

  legendSelected: (e) ->
    {legend, dataZoom} = @chart_view.chart.component
    @rawdataConnect legend._selectedMap, dataZoom._zoom

  rawdataConnect: (selectedMap, zoom) ->
    min = _.min @rawdatas, (rawdata) -> rawdata.year
    max = _.max @rawdatas, (rawdata) -> rawdata.year

    minYear = Math.round min.year + (max.year - min.year) * zoom.start / 100
    maxYear = Math.round min.year + (max.year - min.year) * zoom.end / 100

    rawdatas = _.filter @rawdatas, (rawdata) ->
      minYear <= rawdata.year <= maxYear and selectedMap[rawdata.gender]

    # @indicators.trigger 'rawdatas:method', rawdatas
