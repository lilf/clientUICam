module.exports = transformerOutter = (dateString = 'dateString') ->
    options =
      tooltip:
        trigger: 'axis'
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

      legend:
        data: []
        formatter: (name) -> jade.t name
      calculable: true
      xAxis: [
        type: 'category'
        data: []
      ]
      yAxis: [
        type: 'value'
      ]
      series: []

    transformer = (type, data) ->
      switch type
        when 'date-value'
          options.xAxis[0].data = _.pluck(data, dateString)
          object =
            name: ''
            type: 'bar'
            data: _.pluck data, 'value'
            markPoint:
              data: [
                type: 'max'
                name: '最大值'
              ,
                type: 'min'
                name: '最小值'
              ]
            markLine:
              data: [
                type: 'average'
                name: '平均值'
              ]

          options.series.push object
          options.dataZoom =
              show : true
              realtime : true
              start : 40
              end : 100
          return options
        when 'date-gender-value'
          options.xAxis[0].data = _.uniq(_.pluck(data, dateString))
          group = _.groupBy data, (item) -> item.gender
          legend = _.keys(group)

          options.legend.data = legend
          options.legend.selected =
            MF: false
            M: false
            F: true
          for items, i in _.values(group)
            object =
              name: legend[i]
              type: 'bar'
              data: _.pluck items, 'value'
              markPoint:
                data: [
                  type: 'max'
                  name: '最大值'
                ,
                  type: 'min'
                  name: '最小值'
                ]
              markLine:
                data: [
                  type: 'average'
                  name: '平均值'
                ]
            options.series.push object
          options.dataZoom =
              show : true
              realtime : true
              start : 40
              end : 100

          return options
        when 'date-age-value'
          delete options.dataZoom
          group = _.groupBy data, (item) -> item[dateString]
          option =
            timeline:
              data: []
              label:
                formatter: (s) ->
                  s.slice(0, 4)
              autofalse: true
              playInterval: 1500
            options: [options]

          object =
            type: 'bar'
            data: []

          option.timeline.data = _.keys(group)
          option.options[0].xAxis[0].data = _.pluck(_.values(group)[0], 'age')
          option.options[0].grid = {'y':80,'y2':100}
          values0 = []
          for item in _.values(group)[0]
            values0.push
              name: item.age
              value: item.value
          object.data = values0
          option.options[0].series.push object

          for items in _.rest(_.values(group))
            values = []
            for item in items
              values.push
                name: item.age
                value: item.value
            option.options.push
              series: [
                data: values
              ]

          return option
        when 'date-age-gender-value'
          delete options.dataZoom
          groupGender = _.groupBy data, (item) -> item.gender
          groupYear = _.groupBy data, (item) -> item[dateString]

          option =
            timeline:
              data: []
              label:
                formatter: (s) ->
                  s.slice(0, 10)
              autoPlay: false
              playInterval: 1500
            options: [options]

          option.timeline.data = _.keys groupYear
          option.options[0].xAxis[0].data = _.uniq(_.pluck(_.values(groupYear)[0], 'age'))
          option.options[0].grid = {'y':80,'y2':100}
          legend = _.keys groupGender
          option.options[0].legend.data = legend
          option.options[0].legend.selected =
            MF: false
            M: false
            F: true
          groupYear0 = _.groupBy _.values(groupYear)[0], (item) -> item.gender
          values0 = []
          for items, i in _.values(groupYear0)
            object =
              name: legend[i]
              type: 'bar'
              data: []
            for item in items
              obj =
                name: item.age
                value: item.value
              object.data.push obj
            values0.push object
          option.options[0].series = values0

          for items, i in _.rest(_.values(groupYear))
            group = _.groupBy items, (item) -> item.gender
            object =
              title: ''
              series: []

            for item in _.values(group)
              obj =
                data: []

              for i in item
                o =
                  name: i.age
                  value: i.value
                obj.data.push o
              object.series.push obj
            option.options.push object

          return option

    # $scope.options = transformer(4, data4)
    # console.log transformer(3, data3)


    # $scope.$onRootScope 'renderCommonCharts', (evt, args) ->
    #   console.log data1.length

      # users = _.toArray args.hourPostTrend
      # users = _.map users, (user) ->
      #   user.info = _.findWhere args.users,
      #     id: user.id
      #   user
      # $scope.counts = users

# module.exports = transformerOutter()
