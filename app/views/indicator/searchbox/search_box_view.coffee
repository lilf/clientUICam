module.exports = class SearchboxView extends Backbone.View

  template: require './templates/searchbox'

  option: require './templates/option'

  events:
    'change select[name=indicator_id]': 'go'
    'click .indicator-keyword button': 'addKeyword'

  render: ->
    @$el.html @template()
    @initSelectize()

    this

  go: (e) ->
    indicator_id = e.target.value
    return if indicator_id is ''
    @trigger 'indicator_id', indicator_id

  addOption: (indicator) ->
    @selectize.addOption indicator

  addItem: (indicator_id) ->
    @selectize.addItem indicator_id

  addKeyword: (e) ->
    @addQuery e.target.textContent

  addQuery: (query) ->
    @selectize.removeItem @selectize.getValue()
    @selectize.showInput()
    @selectize.$control_input
    .val query
    .data 'grow', true
    .trigger 'update'
    @selectize.refreshOptions()

  initSelectize: ->
    $select = @$('select[name=indicator_id]')
    .selectize
      valueField: '_id'
      labelField: 'name'
      searchField: ['searchName', 'categories']
      plugins:
        no_results:
          message: jade.t 'No results found.'
      openOnFocus: false
      render:
        option: @option
        item: @option

    @selectize = $select[0].selectize
