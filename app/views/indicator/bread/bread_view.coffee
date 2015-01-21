module.exports = class IndicatorBreadView extends Backbone.View

  template: require './templates/bread'

  events:
    'click a[name=big_name]': 'toBig'
    'click a[name=category_name]': 'toCategory'

  render: ->
    @$el.html @template()

    this

  setBread: (json = {}) ->
    @json = json
    @$('[name=big_name]').text json.big_name or ''
    @$('[name=category_name]').text json.category_name or ''
    @$('[name=indicator_name]').text json.indicator_name

  toBig: (e) ->
    e.preventDefault()
    @trigger 'router:to:category', @json.big_id

  toCategory: (e) ->
    e.preventDefault()
    @trigger 'router:to:category', @json.big_id, @json.category_id
