collection2table = require './collection2table'
timeline = require './timeline_chart_option'
methods = require './methods'
resize_chart = require './resize_chart'
interact = require './interact'

ButtonGroupsView = require './button_groups_view'

delegateEventSplitter = /^(\S+)\s*(.*)$/

window.cid = {}

class TextView extends Backbone.View

  events:
    'dispose:component': 'dispose'

  dispose: ->
    # console.log 'dispose textView'
    @trigger 'dispose'
    @remove()

  setOption: (option) ->
    interact this, option
    @eConsole('initialize')()
    @addEvents option.events
    @$el.html option.template
    $(document).trigger("uk-domready")

  addEvents: (events = {}) ->
    for key of events
      method = events[key]
      continue  unless _.isFunction(method) or key is 'initialize'
      match = key.match(delegateEventSplitter)
      eventName = match[1]
      selector = match[2]
      method = _.bind(@eConsole(key), this)
      eventName += ".delegateEvents" + @cid
      if selector is ""
        @$el.on eventName, method
      else
        @$el.on eventName, selector, method

  eConsole: (name) =>
    (e) => @trigger 'event', name.toLowerCase(), e, @$el

class ChartView extends Backbone.View

  events:
    'dispose:component': 'dispose'
    'rerender:component': 'rerender'

  dispose: ->
    # console.log 'dispose chartView'
    @trigger 'dispose'
    resize_chart.del @chart
    @chart.dispose()
    @chart = null
    @remove()

  rerender: ->
    # console.log 'rerender'
    @chart.resize()

  setOption: (option, overwrite = true) ->
    interact this, option
    @chart.setOption option.echarts, overwrite

  initChart: (option) ->
    { width, height } = option
    width = width or 300
    height = height or 200
    @$el.css { width, height}
    @chart = echarts.init @el
    # window.onresize = @chart.resize
    # @chart.on echarts.config.EVENT.CLICK, @eConsole 'CLICK'
    # # @chart.on echarts.config.EVENT.HOVER, @eConsole
    # @chart.on echarts.config.EVENT.DATA_ZOOM, @eConsole 'DATA_ZOOM'
    # @chart.on echarts.config.EVENT.LEGEND_SELECTED, @eConsole 'LEGEND_SELECTED'
    # @chart.on echarts.config.EVENT.MAGIC_TYPE_CHANGED, @eConsole 'MAGIC_TYPE_CHANGED'
    # @chart.on echarts.config.EVENT.DATA_VIEW_CHANGED, @eConsole 'DATA_VIEW_CHANGED'
    @deletegateEchartsEvents option.events
    @chart.setTheme macarons if window.macarons

    this

  deletegateEchartsEvents: (events = {}) ->
    @chart.on _.string.camelize(eventName), @eConsole eventName for eventName of events

  eConsole: (name) =>
    (e) => @trigger 'event', name.toLowerCase(), e, @$el

class TableView extends Backbone.View

  events:
    'dispose:component': 'dispose'
    'rerender:component': 'rerender'

  dispose: ->
    @trigger 'dispose'
    @remove()

  render:->
    @$tableEl = $ '<table>', class: 'display'
    @$el.html @$tableEl

    this

  rerender: ->
    jqTable = @$tableEl
    if jqTable.length > 0
      # oTableTools =  TableTools.fnGetInstance @$tableEl[0]
      oTableTools =  TableTools.fnGetInstance jqTable[0]
      if oTableTools != null && oTableTools.fnResizeRequired()
        jqTable.dataTable().fnAdjustColumnSizing()
        oTableTools.fnResizeButtons()


  setOption: (option) ->
    interact this, option
    # console.log option.data
    @eConsole('initialize')()
    @addEvents option.events
    { x, y , z, data } = option
    if _.isArray(x) and _.isArray(y) and _.isString(z)
      tableEl = collection2table data, x, y, z
    else
      option.columns = option.columns or _.keys(option.data[0])
      option.th = option.th or _.identity
      option.td = option.td or _.identity

      fileTitle = option.title or ''

      _th = (d1) ->
        t1 = option.th d1
        d2 = if d1.length then d1[0]?.toUpperCase() + d1.slice(1) else d1
        t2 = option.th d2
        if _.isEqual(d2, t2) then t1 else t2

      dataTableOption =
        columns: _.map option.columns, (d) -> data: d, title: _th(d)
        searching: false,
        paging: false,
        "dom": 'T<"clear">lfrtp',
        scrollY: 300,
        "bJQueryUI": true,
        "autoWidth": true,
        "oTableTools": {
          "sSwfPath": "/copy_csv_xls_pdf.swf",
          "aButtons": [
            {
              "sExtends": 'copy',
              "sButtonText": "複製數據",
              "fnComplete": ( nButton, oConfig, oFlash, sFlash )->
                $.UIkit.notify "數據已複製", {pos: "bottom-right"}
            }
            # "copy",
            {
              "sExtends": 'csv',
              "sTitle": fileTitle,
              "bBomInc": true,
              "sButtonText": "導出數據"
            }
            # {
            #   "sExtends": 'pdf',
            #   "sTitle": fileTitle,
            #   "bBomInc": true,
            #   "sButtonText": "導出PDF數據",
            #   "sCharSet": "utf8"
            # }
            # "print"
          ]
        }

      @table = @$tableEl.DataTable dataTableOption

      @table.ersTd = option.td
      @drawTable option.data


  drawTable: (data, columns) ->
    @table.clear()
    for d in data
      d = _.clone d
      d[k] = @table.ersTd v, k, d for k, v of d
      @table.row.add d
    @table.draw()


  addEvents: (events = {}) ->
    for key of events
      method = events[key]
      continue  unless _.isFunction(method) or key is 'initialize'
      match = key.match(delegateEventSplitter)
      eventName = match[1]
      selector = match[2]
      method = _.bind(@eConsole(key), this)
      eventName += ".delegateEvents" + @cid
      if selector is ""
        @$el.on eventName, method
      else
        @$el.on eventName, selector, method

  eConsole: (name) =>
    (e) => @trigger 'event', name.toLowerCase(), e, @$el

exports.text = ($el, option) ->
  textView = new TextView
  $el.html textView.render().el
  textView.setOption option

# exports.chart = ($el, option) ->
#   chartView = new ChartView
#   $el.html chartView.render().el
#   chartView.initChart(option).setOption option

#   window.onresize = chartView.chart.resize

exports.table = ($el, option) ->
  tableView = new TableView
  $el.html tableView.render().el
  tableView.setOption option

exports.buttongroups = ($el, option) ->
  buttongroupsView = new ButtonGroupsView
  $el.html buttongroupsView.render().el
  buttongroupsView.setOption option

# exports.timeline = ($el, option) ->
#   option.echarts = timeline option.echarts
#   exports.chart $el, option

exports.chart = ($el, option) ->
  $el.empty()
  # console.log $el
  option.echarts = [option.echarts] unless _.isArray option.echarts
  option.width = [option.width] unless _.isArray option.width
  option.height = [option.height] unless _.isArray option.height
  general_option = _.omit option, 'echarts', 'type', 'width', 'height'
  charts = _.map option.echarts, (chart_option, i) ->
    # check if it is a timeline chart
    # cause we need to transform it to echarts available timeline chart option first
    # currently out chart option is customized for convinient
    chart_option = timeline chart_option
    width = option.width[i] or option.width[0]
    height = option.height[i] or option.height[0]
    component_option = _.extend { type: 'chart', echarts: chart_option, width: width, height: height }, general_option
    chartView = new ChartView
    $el.append chartView.render().el
    chartView.initChart(component_option).setOption component_option
    chartView.chart

  _.each charts, (chart) ->
    resize_chart.add chart
    other_charts = _.without charts, chart
    _.each other_charts, (other_chart) -> chart.connect other_chart

exports.dispose = ($el) ->
  $el.children().each -> $(this).trigger 'dispose:component'

exports.disposeParent = ($parent) ->
  $parent.children('.component').each -> exports.dispose $(this)

exports.render = ($el, option) ->
  # console.log $el
  exports.dispose $el
  # console.log $el
  $el.addClass option?.className
  $el.attr 'data-component-type', option?.type
  exports[option?.type]? $el, option
  _.delay (-> $el.addClass 'in'), 500
