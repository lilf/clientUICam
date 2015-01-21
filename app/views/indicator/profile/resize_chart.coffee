charts_to_resize = []

setTimeout (-> window.onresize = -> _.invoke charts_to_resize, 'resize'), 200

module.exports =
  add: (chart) ->
    charts_to_resize.push chart

  del: (chart) ->
    i = _.indexOf charts_to_resize, chart
    charts_to_resize.splice i, 1
