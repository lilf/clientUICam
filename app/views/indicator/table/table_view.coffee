module.exports = class IndicatorTableView extends Backbone.View

  template: require './templates/table'

  render: ->
    @$el.html @template()

    this

  initTable: (options = {}) ->
    @table = new ers.Table @th, @td

  th: (x) ->
    jade.t x

  td: (value, key) ->
    switch key
      when 'value' then parseInt (ers.numberWithCommas value).replace /,/g , ''
      when 'gender' then jade.t value
      when 'age' then jade.t value
      else value

  draw: (collection) ->
    @table.draw 'indicator-table', collection
