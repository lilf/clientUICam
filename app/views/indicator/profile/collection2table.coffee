
###
  collection = [
    ['date', 'area']
    ['age', 'gender']
  ]

  collections = [
    [2011, 2022]
    ['east', 'west']
    ['5-15', '15-60', '60+']
    ['male', 'female']
  ]

###

eaches = (arrays = [[]], iterator, context) ->

  limit = _.map arrays, (array) -> array.length
  min_array = _.map limit, -> 0

  _check = (number) ->
    _.every number, (d, i) -> d <= limit[i] - 1

  _setNumber = (number, j) ->
    j = number.length - j
    number[j - 1]++ unless _.isUndefined number[j - 1]
    _.map number, (d, i) -> if i >= j then 0 else d

  addOne = (number) ->
    for i in [0...limit.length]
      new_number = _setNumber number, i
      return new_number if _check new_number

    []

  count = 0 # count

  _iterate = (number) ->
    # return value array
    array = _.map number, (d, i) -> arrays[i][d]
    iterator.call context, array, count++

  times = (number) ->
    # number is like [0,0,1,0] etc..., so the return array.length matches the limit.lenth

    _iterate number
    next_number = addOne number
    # console.log 'next_number: ', next_number
    times next_number unless _.isEmpty next_number

  times min_array


# test eaches

# test_collections = [
#   [2011, 2022]
#   ['east', 'west']
#   ['5-15', '15-60', '60+']
#   ['male', 'female']
# ]

# eaches test_collections, (p, i) -> console.log p, i

maps = (arrays = [[]], iterator, context) ->
  iterator ?= _.identity
  results = []
  eaches arrays, (p, i) -> results.push iterator.call context, p, i
  results

axiser = (arrays = [[]]) ->
  results = []

  nodes = maps arrays

  links = []

  for d, i in nodes
    diffs = _.difference d, nodes[i - 1]
    sames = _.without d, diffs...

    for diff, j in diffs
      j = _.indexOf d, diff
      current_element = x: j, y: i, value: diff, span: 1
      results.push current_element

      if links[j]
        links.splice j, 1, current_element
      else
        links.push current_element

    for same, k in sames
      k = _.indexOf d, same
      previous_element = _.findWhere links, x: k, value: same
      previous_element?.span++

  results

# test axis
# test_collections = [
#   ['a1', 'a2']
#   ['b1', 'b2', 'b3']
#   ['c1', 'c2', 'c3']
# ]

# test_axis = axis test_collections
# console.log test_axis, test_axis.length

collection2table = (collection = [], x = [], y = [], z = '') ->
  return unless collection.length and (x.length or y.length) and z isnt ''

  keys = _.keys collection[0]
  collection_length = collection.length
  keys_length = keys.length
  x_length = x.length
  y_length = y.length
  columns_length = x_length + y_length

  return unless keys.length and keys.length is columns_length + 1

  extendAxis = (names, _axis) ->
    _.map names, (column) -> name: column, axis: _axis, keys: _.chain(collection).pluck(column).uniq().value()

  x_columns = extendAxis x, 'x'
  y_columns = extendAxis y, 'y'

  columns = [].concat x_columns, y_columns

  column_names = _.map columns, (column) -> column.name
  column_value_ranges = _.map columns, (column) -> column.keys

  x_column_value_ranges = _.map x_columns, (column) -> column.keys
  y_column_value_ranges = _.map y_columns, (column) -> column.keys

  x_nodes = maps x_column_value_ranges
  y_nodes = maps  y_column_value_ranges

  getIndex = (_nodes, _position) ->
    for _node, i in _nodes
      return i if _.every _node, (d, ii) -> d is _position[ii]
    0

  tds = maps column_value_ranges, (column_values, i) ->

    json = _.object column_names, column_values

    td = {}

    # get x, y
    x_positions = column_values.slice 0, x_length
    y_positions = column_values.slice x_length

    td.y = getIndex x_nodes, x_positions
    td.x = getIndex y_nodes, y_positions

    td.tagName = 'td'
    td.rowspan = 1
    td.colspan = 1

    # get value
    result = _.findWhere collection, json
    td.value = if result then result[z] else '-'

    td

  xAxis = axiser x_column_value_ranges

  xAxis = _.map xAxis, (x_axis) ->
    { x, y, value, span } = x_axis

    tx =
      x: x
      y: y + y_length
      value: value
      rowspan: span
      colspan: 1
      tagName: 'th'

    tx

  yAxis = axiser y_column_value_ranges

  yAxis = _.map yAxis, (y_axis) ->
    { x, y, value, span } = y_axis

    x: y + x_length
    y: x
    value: value
    rowspan: 1
    colspan: span
    tagName: 'th'

  empty_cell =
    x: 0
    y: 0
    value: '#'
    rowspan: y_length
    colspan: x_length
    tagName: 'th'

  empty_cell = [] if x_length is 0 or y_length is 0

  tds = _.map tds, (td) ->
    td.x += x_length
    td.y += y_length
    td

  [].concat empty_cell, xAxis, yAxis, tds


createTable = (_cells) ->
  table = document.createElement 'table'
  table.className = 'uk-table'
  thead = document.createElement 'thead'
  table.appendChild thead
  tbody = document.createElement 'tbody'
  table.appendChild tbody
  # document.body.appendChild table

  _.chain _cells
    .groupBy 'y'
    # .map (values, key) -> { key, values }
    # .sortBy 'key'
    # .each (row) ->
      # { key, values } = row
      # values = _.sortBy values, 'x'
    .each (values, key) ->
      tr = document.createElement 'tr'
      tr.id = 'tr' + key
      _.each values, (d) ->
        tx = document.createElement d.tagName
        tx.rowSpan = d.rowspan
        tx.colSpan = d.colspan
        tx.textContent = d.value
        tr.appendChild tx

      if _.every(values, (d) -> d.tagName is 'th')
        thead.appendChild tr
      else
        tbody.appendChild tr

  table

module.exports = (collection, x, y, z) ->

  cells = collection2table collection, x, y, z
  createTable cells

# test collection2table

# $ ->
#   cells = collection2table ers.data2, ['a', 'b'], ['c', 'd'] , 'value'
#   createTable cells

# echart_data = [{"category":"Aware the Club is a not-for-profit organization","answer":"Positive","source":"Sky Post","id":1},{"category":"Community Contribution","answer":"Negative","source":"HK Economic Times","id":2},{"category":"Community Contribution","answer":"Neutral","source":"Wen Wei Po 文匯報","id":1},{"category":"Community Contribution","answer":"Positive","source":"Apple Daily","id":1},{"category":"Community Contribution","answer":"Positive","source":"Capital Weekly 資本壹周","id":1},{"category":"Community Contribution","answer":"Positive","source":"HK Daily News","id":3},{"category":"Community Contribution","answer":"Positive","source":"Headline Daily 頭條日報","id":1},{"category":"Community Contribution","answer":"Positive","source":"Sing Pao Daily News","id":1},{"category":"Community Contribution","answer":"Positive","source":"Sing Tao Daily","id":2},{"category":"Community Contribution","answer":"Positive","source":"Sing Tao Daily 星島日報","id":2},{"category":"Community Contribution","answer":"Positive","source":"South China Morning Post","id":2},{"category":"Community Contribution","answer":"Positive","source":"Ta Kung Pao","id":3},{"category":"Community Contribution","answer":"Positive","source":"Wen Wei Po","id":2},{"category":"Innovation & Customer Services","answer":"Negative","source":"HK Commercial Daily 香港商報","id":1},{"category":"Innovation & Customer Services","answer":"Negative","source":"HK Daily News 新報","id":1},{"category":"Innovation & Customer Services","answer":"Negative","source":"Ming Pao Daily News","id":1},{"category":"Innovation & Customer Services","answer":"Negative","source":"Sing Pao Daily News","id":1},{"category":"Innovation & Customer Services","answer":"Negative","source":"Sing Tao Daily","id":2},{"category":"Innovation & Customer Services","answer":"Neutral","source":"HK Daily News","id":1},{"category":"Innovation & Customer Services","answer":"Neutral","source":"Oriental Daily News","id":1},{"category":"Innovation & Customer Services","answer":"Neutral","source":"Sing Tao Daily","id":3},{"category":"Innovation & Customer Services","answer":"Neutral","source":"The Sun","id":1},{"category":"Innovation & Customer Services","answer":"Positive","source":"HK Daily News","id":1},{"category":"Innovation & Customer Services","answer":"Positive","source":"Sing Pao Daily News","id":2},{"category":"Innovation & Customer Services","answer":"Positive","source":"Sing Tao Daily","id":2},{"category":"Innovation & Customer Services","answer":"Positive","source":"Sky Post","id":1},{"category":"Prestigious Membership Club","answer":"Negative","source":"Apple Daily","id":1},{"category":"Prestigious Membership Club","answer":"Negative","source":"HK Daily News","id":1},{"category":"Prestigious Membership Club","answer":"Negative","source":"Oriental Daily News 東方日報","id":1},{"category":"Prestigious Membership Club","answer":"Negative","source":"Sing Tao Daily","id":1},{"category":"Prestigious Membership Club","answer":"Positive","source":"Apple Daily","id":1},{"category":"Prestigious Membership Club","answer":"Positive","source":"Apple Daily 蘋果日報","id":1},{"category":"Prestigious Membership Club","answer":"Positive","source":"Capital Weekly","id":1},{"category":"Prestigious Membership Club","answer":"Positive","source":"Eastweek","id":1},{"category":"Prestigious Membership Club","answer":"Positive","source":"Headline Daily","id":1},{"category":"Prestigious Membership Club","answer":"Positive","source":"Oriental Daily News 東方日報","id":1},{"category":"Prestigious Membership Club","answer":"Positive","source":"Sing Tao Daily 星島日報","id":1},{"category":"Recognize the Club as a major & desirable employer","answer":"Negative","source":"HK Daily News","id":1},{"category":"Recognize the Club as a major & desirable employer","answer":"Neutral","source":"HK Daily News","id":1},{"category":"Recognize the Club as a major & desirable employer","answer":"Positive","source":"Sing Tao Daily","id":1},{"category":"Recognize the Club as a major & desirable employer","answer":"Positive","source":"South China Morning Post","id":1},{"category":"Responsible Gambling","answer":"Negative","source":"Apple Daily 蘋果日報","id":1},{"category":"Responsible Gambling","answer":"Negative","source":"HK Commercial Daily 香港商報","id":1},{"category":"Responsible Gambling","answer":"Negative","source":"HK Daily News 新報","id":1},{"category":"Responsible Gambling","answer":"Negative","source":"Headline Daily","id":2},{"category":"Responsible Gambling","answer":"Negative","source":"Ming Pao Daily News","id":1},{"category":"Responsible Gambling","answer":"Negative","source":"Oriental Daily News 東方日報","id":1},{"category":"Responsible Gambling","answer":"Negative","source":"Sing Tao Daily","id":2},{"category":"Responsible Gambling","answer":"Negative","source":"Sky Post","id":1},{"category":"Responsible Gambling","answer":"Negative","source":"Ta Kung Pao","id":1},{"category":"Responsible Gambling","answer":"Negative","source":"The Standard","id":2},{"category":"Responsible Gambling","answer":"Negative","source":"Wen Wei Po","id":1},{"category":"Responsible Gambling","answer":"Negative","source":"Wen Wei Po 文匯報","id":1},{"category":"Responsible Gambling","answer":"Neutral","source":"Apple Daily","id":1},{"category":"Responsible Gambling","answer":"Neutral","source":"Sing Tao Daily","id":1},{"category":"Responsible Gambling","answer":"Neutral","source":"South China Morning Post","id":1},{"category":"Responsible Gambling","answer":"Neutral","source":"South China Morning Post 南華早報","id":1},{"category":"Responsible Gambling","answer":"Neutral","source":"Wen Wei Po","id":2},{"category":"Responsible Gambling","answer":"Positive","source":"Apple Daily","id":2},{"category":"Responsible Gambling","answer":"Positive","source":"Sing Tao Daily","id":2},{"category":"Responsible Gambling","answer":"Positive","source":"Sing Tao Daily 星島日報","id":1},{"category":"Responsible Gambling","answer":"Positive","source":"Ta Kung Pao","id":1},{"category":"Responsible Gambling","answer":"Positive","source":"The Standard","id":1},{"category":"Responsible Gambling","answer":"Positive","source":"Wen Wei Po","id":1},{"category":"World Class Racing Sports","answer":"Negative","source":"Apple Daily","id":5},{"category":"World Class Racing Sports","answer":"Negative","source":"Apple Daily 蘋果日報","id":3},{"category":"World Class Racing Sports","answer":"Negative","source":"HK Commercial Daily","id":1},{"category":"World Class Racing Sports","answer":"Negative","source":"HK Daily News","id":10},{"category":"World Class Racing Sports","answer":"Negative","source":"HK Daily News 新報","id":3},{"category":"World Class Racing Sports","answer":"Negative","source":"Headline Daily","id":1},{"category":"World Class Racing Sports","answer":"Negative","source":"Ming Pao Daily News","id":2},{"category":"World Class Racing Sports","answer":"Negative","source":"Ming Pao Daily News 明報","id":2},{"category":"World Class Racing Sports","answer":"Negative","source":"Oriental Daily News","id":4},{"category":"World Class Racing Sports","answer":"Negative","source":"Sing Pao Daily News","id":1},{"category":"World Class Racing Sports","answer":"Negative","source":"Sing Pao Daily News 成報","id":1},{"category":"World Class Racing Sports","answer":"Negative","source":"Sing Tao Daily","id":7},{"category":"World Class Racing Sports","answer":"Negative","source":"Sing Tao Daily 星島日報","id":2},{"category":"World Class Racing Sports","answer":"Negative","source":"South China Morning Post 南華早報","id":1},{"category":"World Class Racing Sports","answer":"Negative","source":"The Sun","id":4},{"category":"World Class Racing Sports","answer":"Negative","source":"Wen Wei Po","id":1},{"category":"World Class Racing Sports","answer":"Neutral","source":"Apple Daily 蘋果日報","id":1},{"category":"World Class Racing Sports","answer":"Neutral","source":"HK Commercial Daily","id":1},{"category":"World Class Racing Sports","answer":"Neutral","source":"HK Daily News","id":2},{"category":"World Class Racing Sports","answer":"Neutral","source":"HK Daily News 新報","id":1},{"category":"World Class Racing Sports","answer":"Neutral","source":"Oriental Daily News","id":1},{"category":"World Class Racing Sports","answer":"Neutral","source":"Sing Tao Daily","id":1},{"category":"World Class Racing Sports","answer":"Neutral","source":"Sing Tao Daily 星島日報","id":2},{"category":"World Class Racing Sports","answer":"Neutral","source":"South China Morning Post","id":1},{"category":"World Class Racing Sports","answer":"Positive","source":"Apple Daily 蘋果日報","id":4},{"category":"World Class Racing Sports","answer":"Positive","source":"Capital Weekly","id":3},{"category":"World Class Racing Sports","answer":"Positive","source":"HK Commercial Daily","id":1},{"category":"World Class Racing Sports","answer":"Positive","source":"HK Daily News","id":2},{"category":"World Class Racing Sports","answer":"Positive","source":"HK Daily News 新報","id":1},{"category":"World Class Racing Sports","answer":"Positive","source":"Headline Daily","id":1},{"category":"World Class Racing Sports","answer":"Positive","source":"Ming Pao Daily News","id":1},{"category":"World Class Racing Sports","answer":"Positive","source":"Oriental Daily News 東方日報","id":1},{"category":"World Class Racing Sports","answer":"Positive","source":"Professional Racing Journal 專業馬訊","id":1},{"category":"World Class Racing Sports","answer":"Positive","source":"Sing Tao Daily","id":5},{"category":"World Class Racing Sports","answer":"Positive","source":"Sing Tao Daily 星島日報","id":2},{"category":"World Class Racing Sports","answer":"Positive","source":"Sky Post","id":1},{"category":"World Class Racing Sports","answer":"Positive","source":"South China Morning Post","id":3},{"category":"World Class Racing Sports","answer":"Positive","source":"South China Morning Post 南華早報","id":1},{"category":"World Class Racing Sports","answer":"Positive","source":"The Sun","id":2},{"category":"World Class Racing Sports","answer":"Positive","source":"Wen Wei Po 文匯報","id":1}]
# $ ->
#   # cells = collection2table ers.data2, ['a', 'b'], ['c', 'd'] , 'value'
#   cells = collection2table echart_data, ['source'], ['category', 'answer'] , 'id'
#   createTable cells

  # findRowPosition = (row) ->
  #   cell = _.chain columns
  #     .map (column) ->
  #       { name, axis, length, keys } = column
  #       value = _.indexOf keys, row[name]

  #       { name, value, length, axis }
  #     .groupBy 'axis'
  #     .map (positions, axis) ->
  #       position = getAxisPosition positions
  #       [axis, position]
  #     .object()
  #     .value()

  #   cell.x = cell.x + x_length
  #   cell.y = cell.y + y_length
  #   cell.value = row[z]
  #   cell.className = 'td'

  #   cell

  # findColumnPostion = (column) ->
  #   x_postions = _.map x_columns, (x_column) ->



  #   cell = {}
  #   cell.x = getAxisPosition x_postions
  #   cell.y = getAxisPosition y_positions

  #   cell.value = column.name
  #   cell.className = 'th'

  #   cell



  # getAxisPosition = (positions = []) ->
  #   _.reduce positions, (
  #     (sum, position) ->
  #       { value, length } = position
  #       sum * length + value
  #     ), 0


