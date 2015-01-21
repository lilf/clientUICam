module.exports = (rawdatas, sources, indicator) ->
  rawdatas = _.sortBy rawdatas, 'year'
  columns = _.keys rawdatas[0]
  groupByYear = _.groupBy rawdatas, 'year'
  groupByGender = _.groupBy rawdatas, 'gender'

  genders = _.keys groupByGender
  years = _.keys groupByYear
  series = for key, value of groupByGender
    name: key
    type: 'line'
    data: _.map value, (d) -> d.value

  return {} unless rawdatas.length

  # start
  title:
    text: indicator.name

  legend:
    data: genders
    formatter: (name) -> jade.t name
    selected:
      MF: false
      M: false
      F: true

  xAxis: [
    type: "category"
    boundaryGap: false
    data: years
  ]
  yAxis: [
    type: "value"
    scale: true
    power: 10000
    splitArea:
      show: true
  ]
  series: series

# end
  calculable: true
  dataZoom :
      show : true
      realtime : true
      start : 40
      end : 100
  tooltip:
    trigger: "axis"
    formatter: (params, ticket, callback) ->
      params = _.map params, (param) ->
        _.map param, (d, i) ->
          switch columns[i]
            when 'gender' then jade.t d
            else d
      startString = "Function formatter :<br/>"
      res = '' + params[0][1]
      i = 0
      l = params.length

      while i < l
        res += "<br/>" + params[i][0] + " : " + params[i][2]
        i++

      res

  toolbox:
    show: true
    feature:
      mark:
        show: true
        title:
          mark: '輔助線開關'
          markUndo: '刪除輔助線'
          markClear: '清空輔助線'
      dataZoom:
        show: true
        title:
          dataZoom: '區域縮放'
          dataZoomReset: '區域縮放後退'
      # dataView:
      #   show: true
      #   readOnly: false

      magicType:
        show: true
        type: [
          "line"
          "bar"
          "stack"
          "tiled"
        ]
        title:
          line: '折線圖切換'
          bar: '柱形圖切換'
          stack: '堆積'
          tiled: '平鋪'

      restore:
        show: true
        title: '還原'

      saveAsImage:
        show: true
        title: '保存為圖片'
        lang: ['點擊保存']

