IndicatorTableView = require './table_view'
module.exports = class IndicatorTableNode extends Backbone.Node

  requires:
    indicators: 'indicators'
    bigModes: 'bigModes'

  initialize: ->
    @table_view = new IndicatorTableView
    $('#indicator_table_view').html @table_view.render().el

  ready: ->
    @table_view.initTable()
    @listenTo @indicators, 'rawdatas:method', @drawTable
    @listenTo @indicators, 'add:item', @addItem
    @listenTo @indicators, 'change:mode', @changeMode

    @listenTo @bigModes, 'bigModes:table:option', @drawByOption

  drawByOption: (datas) ->
    @drawTable datas

  addItem: (@indicator_id) ->

  changeMode: (rawdatas, sources, indicator) ->
    @rawdatas = rawdatas
    @table_view.draw rawdatas, sources, indicator

  drawTable: (rawdatas) ->
    @table_view.draw rawdatas

