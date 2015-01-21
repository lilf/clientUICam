module.exports = class IndicatorSummaryView extends Backbone.View

  template: require './templates/summary'

  info: require './templates/info'

  className: 'uk-margin-small-top'

  events:
    'change select[name=mode_id]': 'changeMode'

  render: ->
    @$el.html @template()
    @$el.ukMargin()

    this

  renderInfo: (data) ->
    data.dateLatest = moment(data.dateLatest, 'YYYYMMDD').format('YYYY/MM/DD')
    data.minDate = moment(data.minDate, 'YYYYMMDD').format('YYYY/MM/DD')
    data.maxDate = moment(data.maxDate, 'YYYYMMDD').format('YYYY/MM/DD')
    @$(' dl.uk-description-list').html @info data

  changeMode: (e) ->
    @trigger 'change:mode', e.target.value

  renderModes: (modes) ->
    @$('select[name=mode_id]')
    .html @renderOptions modes
    .trigger 'change'

  renderOptions: (collection) ->
    _.map collection, (json) -> $ '<option>', value: json._id, text: json.name
