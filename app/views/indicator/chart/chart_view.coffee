options = require './options'
loading = require './loading'

module.exports = class IndicatorChartView extends Backbone.View

  template: require './templates/chart'

  render: ->
    @$el.html @template()

    this

  start: ->
    @chart.showLoading loading(3)

  end: ->
    @chart.hideLoading()

  initChart: ->
    @chart = echarts.init document.getElementById 'indicator-chart'
    window.onresize = @chart.resize
    @chart.on echarts.config.EVENT.CLICK, @eConsole 'CLICK'
    # @chart.on echarts.config.EVENT.HOVER, @eConsole
    @chart.on echarts.config.EVENT.DATA_ZOOM, @eConsole 'DATA_ZOOM'
    @chart.on echarts.config.EVENT.LEGEND_SELECTED, @eConsole 'LEGEND_SELECTED'
    @chart.on echarts.config.EVENT.MAGIC_TYPE_CHANGED, @eConsole 'MAGIC_TYPE_CHANGED'
    @chart.on echarts.config.EVENT.DATA_VIEW_CHANGED, @eConsole 'DATA_VIEW_CHANGED'
    @chart.setTheme macarons

    @chart

  eConsole: (name) =>
    name = 'chart:' + name
    (e) => @trigger name.toLowerCase(), e

  drawByData: (rawdatas, sources, indicator) ->
    option = options rawdatas, sources, indicator
    @chart.setOption option, true

  setOption: (option) ->
    @end()
    @chart.component.timeline.stop() if @chart.component.timeline
    @chart.clear()
    @chart.setOption option, true
