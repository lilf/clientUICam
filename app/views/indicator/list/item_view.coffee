module.exports = class ItemView extends Backbone.View

  template: require './templates/item'

  badge: require './templates/badge'

  tagName: 'li'

  id: -> @model.cid

  events:
    'click .indicator-card-button': 'click'

  initialize: ->
    @listenTo @model, 'remove', @remove
    @listenTo @model, 'latest', @latest
    @listenTo @model, 'notFound', @notFound

  render: ->
    @$el.html @template @model.toJSON()
    @model.fetLatestInfo()

    this

  click: ->
    @model.trigger 'indicator_id', @model.get '_id' if @model.get 'hasData'

  notFound: ->
   @$('.indicator-badge').html '暫無數據'

  latest: (data) ->
    # transformDate = data.date.substr(0,4) + '/' + data.date.substr(4,2) + '/' + data.date.substr(6,2)
    transformDate = @transformDate data.date, data.rawdata.dateType
    data.date = transformDate
    @$('.indicator-badge').html @badge data

  transformDate: (date, dateType) ->
    m = moment date, "YYYYMMDD"
    switch dateType
      when 'year' then  m.get('year')
      when 'quarter' then m.get('year') + 'Q' + m.get('quarter')
      when 'month' then m.get('year') + '/' + (m.get('month') + 1)


