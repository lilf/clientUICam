# fixture_option = [
#   {
#     name: 'trend'
#     dateType: 'year'
#     className: 'gender+year+value'
#   }
#   {
#     name: 'trend'
#     dateType: 'quarter'
#     className: 'gender+year+quarter+value'
#   }
#   {
#     name: 'age'
#     dateType: 'year'
#     className: 'age+gender+year+value'
#   }
# ]

# fixture_data = [
#   {
#     name: 'modes'
#     buttons: [
#       { name: 'trend', selected: true}
#       { name: 'age', selected: false}
#     ]
#   }
#   {
#     name: 'dates'
#     buttons: [
#       { name: 'year', selected: true }
#       { name: 'quarter', selected: true }
#     ]
#   }
# ]


pareseResults = (Modes, e)->
  year = /year/
  quarter = /quarter/
  month = /month/
  mode1 = []
  modes = []
  dates = []
  className = []
  mode3 = []
  # dataNew = []

  i = 0
  while i < Modes.length
    left_paren_index = Modes[i].name.indexOf '('
    modes[i] = Modes[i].name.substr 0, left_paren_index
    className[i] = Modes[i].name.substring left_paren_index + 1, Modes[i].name.length-1
    # console.log not quarter.test className[i]
    # console.log year.test className[i]
    # console.log (year.test className[i]) and (not quarter.test className[i])
    if (year.test className[i]) and (not quarter.test className[i]) and (not month.test className[i])
      dates[i] = '年'
    if (quarter.test className[i]) and (not month.test className[i])
      dates[i] = '季'
    if month.test className[i]
      dates[i] = '月'
    mode1.push {
      modes: modes[i]
      dates: dates[i]
      className: className[i]
      }
    i++

  # modes = _.map Modes, (mode) -> mode.name.substr 0, 2
  # className = _.map Modes, (mode) -> mode.name.substring 3, mode.name.length-1
  # dates = _.map Modes, (mode) ->
  #   return '季' if quarter.test mode.name
  #   return '年' unless quarter.test mode.name
  # mode1.push
  #   modes: modes
  #   dates: dates
  #   className: className

  # console.log mode1


  modes = _.uniq _.pluck mode1, 'modes'
  modes = _.map modes, (modeName) -> name: modeName, type: 'modes', selected: false

  mode = _.findWhere modes, name: e.modes
  mode = modes[0] unless mode
  mode.selected = true


  recordsByMode = _.where mode1, modes: mode.name
  dates = _.uniq _.pluck recordsByMode, 'dates'
  dates = _.map dates, (dateName) -> name: dateName, type: 'dates', selected: false
  date = _.findWhere dates, name: e.dates
  date = dates[0] unless date
  date.selected = true


  results = [
    {
      name: 'modes'
      buttons: modes
    }
    {
      name: 'dates'
      buttons: dates
    }
  ]

  # console.log mode1, results

  [mode1, results]

  # i = 0
  # modes_type = []
  # dates_type = []
  # while i < mode1.length
  #   modes_type[i] = mode1[i].modes
  #   dates_type[i] = mode1[i].dates
  #   i++
  # modes_type = _.uniq modes_type
  # dates_type = _.uniq dates_type

  # i = 0
  # mode2 = []
  # # mode4 = []
  # while i < modes_type.length
  #   if i is 0
  #     mode2.push {
  #       name: modes_type[i]
  #       type: 'modes'
  #       selected: true
  #     }
  #   else
  #     mode2.push {
  #       name: modes_type[i]
  #       type: 'modes'
  #       selected: false
  #     }
  #   i++

  # i = 0
  # while i < dates_type.length
  #   if i is 0
  #     mode2.push {
  #       name: dates_type[i]
  #       type: 'dates'
  #       selected: true
  #     }
  #   else
  #     mode2.push {
  #       name: dates_type[i]
  #       type: 'dates'
  #       selected: false
  #     }
  #   i++

  # # console.log mode4
  # # console.log mode4

  # if _.isEmpty e
  #   i = 0
  #   while i < mode2.length
  #     mode3.push mode2[i]
  #     i++
  # else
  #   i = 0
  #   # mode2 = _.map mode2, (mode) -> mode.set 'selected', false
  #   while i < mode2.length
  #     mode2[i].selected = false
  #     i++

  #   i = 0
  #   while i < mode2.length
  #     if mode2[i].name == e.modes || mode2[i].name == e.dates
  #        mode2[i].selected = true
  #     i++

  #   i = 0
  #   if e.modes == '年齡'
  #     while i < mode2.length
  #       if mode2[i].name != '季'
  #         mode3.push mode2[i]
  #       i++
  #   else
  #     i = 0
  #     while i < mode2.length
  #       mode3.push mode2[i]
  #       i++
  #   if e.dates == ''

  # modesButton = []
  # datesButton = []
  # modeResult = []
  # i = 0
  # while i < mode3.length
  #   if mode3[i].type == 'modes'
  #     modesButton.push {
  #       name: mode3[i].name
  #       selected: mode3[i].selected
  #     }
  #   else
  #     datesButton.push {
  #       name: mode3[i].name
  #       selected: mode3[i].selected
  #     }
  #   i++

  # modeResult.push {
  #   name: 'modes'
  #   buttons: modesButton
  # }
  # modeResult.push {
  #   name: 'dates'
  #   buttons: datesButton
  # }
  # [mode1, modeResult]


class ButtonItemView extends Backbone.View

  template: (json) ->
    $ '<span>', text: json.name

  tagName: 'button'

  className: ->
    selected = @model.get 'selected'
    if selected then 'uk-button uk-active' else 'uk-button'

  events:
    'click': 'click'

  initialize: ->
    @listenTo @model, 'remove', @remove

  render: ->
    @$el.html @template @model.toJSON()

    this

  click: ->
    @model.trigger 'button:active', @model.get 'name'


class ButtonGroupView extends Backbone.View

  template: require './templates/button_group'

  tagName: 'span'

  className: 'button-group'

  initialize: ->
    @collection = @model.get 'buttons'
    @listenTo @collection, 'button:active', @buttonActived
    @listenTo @model, 'remove', @removeAll

  removeAll: ->
    @collection.remove @collection.models
    @remove()

  toggleActive: (buttonName) ->
    current_selected = @collection.findWhere selected: true
    current_selected.set 'selected', false
    next_selected = @collection.findWhere name: buttonName
    next_selected.set 'selected', true

  buttonActived: (buttonName) ->
    @toggleActive buttonName
    name = @model.get 'name'
    @model.trigger 'button:group:active', [name, buttonName]

  render: ->
    @$el.html @template @model.toJSON()
    @$list = @$ '.uk-button-group'
    @$list.addClass 'only-one-button' if @collection.length is 1
    @renderItems()

    this

  renderItem: (model) ->
    item_view = new ButtonItemView {model}
    @$list.append item_view.render().el

  renderItems: ->
    @collection.each @renderItem, this

module.exports = class ButtonGroupsView extends Backbone.View

  events:
    'dispose:component': 'dispose'

  dispose: ->
    # console.log 'dispose buttonGroupsView'
    @trigger 'dispose'
    @showNextAll()
    @collection.reset()
    @option = null
    @collection = null
    @remove()

  setOption: (option) ->
    @option = option
    # @modes = fixture_option
    @collection = new Backbone.Collection
    @listenTo @collection, 'button:group:active', @buttonGroupActived
    @listenTo @collection, 'reset', @renderItems
    @buttonGroupActived()

  getStatus: (e) ->
    # console.log 'sta', e
    status = @collection.map (model) ->
      { name, buttons } = model.toJSON()
      # console.log 'buttons', buttons.toJSON()
      selectedButton = buttons.findWhere selected: true

      [name, selectedButton.toJSON().name]
    _.object status

  buttonGroupActived: (e) ->
    # e = [ 'modes', 'trend']
    newE = @getStatus e
    @generateNewButtons newE

  generateNewButtons: (e) ->
    # e = modes: 'age', dates: 'year'
    [classNames, button_options] = pareseResults @option.modes, e
    # console.log button_options
    @active e, classNames
    @reset button_options

  reset: (modes) ->
    # @collection.each (model) ->
    #   buttons = model.get 'buttons'
    #   buttons.reset()
    modes = _.map modes, (mode) ->
      mode.buttons = new Backbone.Collection mode.buttons
      mode
    @collection.remove @collection.models
    @collection.reset modes

  active: (e, classNames) ->
    # e = [{name: 'modes', button: 'age'}, { name: 'dates', button: 'year'}]
    # e = modes: 'age', dates: 'year'

    className = @getClassName e, classNames
    @showRelatedComponentsByClassName className unless @option.test

  getClassName: (e, classNames) ->
    # console.log 'origin e: ', e
    conditions = _.pairs e
    for i in [conditions.length..0]
      newE = _.object conditions.slice 0, i
      # console.log 'newE: ', newE
      option = _.findWhere classNames, newE
      return option.className if option?.className

  showRelatedComponentsByClassName: (className) ->
    $el = @$el.parent()
    # @$el.parent().addClass className
    # console.log className
    $el.nextAll('.component').hide()
    $el.nextAll('.component.' + className).show().children().trigger('rerender:component')

  showNextAll: ->
    $el = @$el.parent()
    # @$el.parent().addClass className
    # console.log className
    $el.nextAll('.component').show()

  renderItem: (model) ->
    item_view = new ButtonGroupView {model}
    @$el.append item_view.render().el

  renderItems: ->
    @collection.each @renderItem, this
