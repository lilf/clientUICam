IndicatorAnalyzeView = require './analyze_view'

module.exports = class IndicatorAnalyzeNode extends Backbone.Node

  initialize: ->
    @analyze_view = new IndicatorAnalyzeView
    $('#indicator_analyze_view').html @analyze_view.render().el
