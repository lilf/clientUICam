(function(echarts) {

  echarts = echarts || {};
  echarts.ers = echarts.ers || {};
  echarts.ers.saveAsImage = function (){
    var toolbox = this;
    var myChart = this.myChart;
    var currentIndex;
    var dataZoom = false;
    var autoPlay;
    var imageType;
    var currentOption = {};
    var chartOption = myChart._optionRestore;

    function hide () {
      if (myChart._timeline) {
        // hide timeline
        myChart._timeline.stop();
        currentIndex = myChart._timeline.currentIndex;

        var timeline_option = myChart._timeline.option;
        timeline_option.timeline.show = false;
        autoPlay = timeline_option.timeline.autoPlay;
        timeline_option.timeline.autoPlay = false;

        var firstOption = timeline_option.options[0];

        if (firstOption.dataZoom && firstOption.dataZoom.show === true) {
          dataZoom = true;
          firstOption.dataZoom.show = false;
        };

        if (firstOption.toolbox.dataZoom && firstOption.toolbox.dataZoom.show === true) {
          dataZoom = true;
          firstOption.toolbox.dataZoom.show = false;
        };

        firstOption.toolbox.show = false;

        myChart.setOption(timeline_option);

      } else{
        // hide dataZoom
        if (chartOption.dataZoom && chartOption.dataZoom.show === true) {
          dataZoom = true
          currentOption.dataZoom = {};
          currentOption.dataZoom.show = false;
        };

        if (chartOption.toolbox.feature.dataZoom && chartOption.toolbox.feature.dataZoom.show === true) {
          dataZoom = true;
          currentOption.toolbox = {};
          currentOption.toolbox.feature = {};
          currentOption.toolbox.feature.dataZoom = false;
        }
        // hide toolbox
        currentOption.toolbox = {};
        currentOption.toolbox.show = false;
        myChart.setOption(currentOption);
      };

    }

    function show () {

      if (myChart._timeline) {
        // show timeline
        myChart._timeline.stop();
        currentIndex = myChart._timeline.currentIndex;

        var timeline_option = myChart._timeline.option;
        timeline_option.timeline.show = true;
        timeline_option.timeline.autoPlay = autoPlay;

        var firstOption = timeline_option.options[0];

        if (firstOption.dataZoom && dataZoom) {
          dataZoom = false;
          firstOption.dataZoom.show = true;
        };

        if (firstOption.toolbox.dataZoom && dataZoom) {
          dataZoom = false;
          firstOption.toolbox.dataZoom.show = true;
        };

        firstOption.toolbox.show = true;

        myChart.setOption(timeline_option);
        myChart._timeline.currentIndex = currentIndex;
        myChart._timeline._setCurrentOption();

      } else{
        // show dataZoom
        if (chartOption.dataZoom && dataZoom) {
          dataZoom = false;
          currentOption.dataZoom.show = true;
        };

        if (chartOption.toolbox.feature.dataZoom && dataZoom) {
          dataZoom = false;
          currentOption.toolbox.feature.dataZoom = true;
        }
        // show toolbox
        currentOption.toolbox.show = true;
        myChart.setOption(currentOption);
      };

    }

    function saveAsImageByType (type) {
      toolbox.option.toolbox.feature.saveAsImage.type = type;
      toolbox._onSaveAsImage();
    }

    function hideTooltip () {
      $('.uk-tooltip.uk-tooltip-top').hide();
    }

    function dialogue (callback) {
      if (window.alertify) {
        window.alertify.set({ labels: {
            ok     : "PNG",
            cancel : "JPEG"
        } });

        $close_button = $('<button data-uk-tooltip>')
        .attr('title', jade.t('cancel saveAsImage'))
        .addClass('uk-close')
        .css({
          position: 'fixed',
          'z-index': '199999',
          top: '55px',
          left: '50%',
          'margin-left': '245px'

        })
        .on('click', function() {
          $("#alertify-cover").remove();
          $("#alertify-logs").remove();
          $('#alertify').remove();
          hideTooltip();
          $(this).remove();
          callback();
        })
        .appendTo($('body'));
        // confirm dialog
        window.alertify.confirm(jade.t('Please choose image type to export'), function (e) {

            if (e) {
                // user clicked "ok"
                saveAsImageByType('png');
            } else {
                // user clicked "cancel"
                saveAsImageByType('jpeg');
            }
            $close_button.remove();
            hideTooltip();
            callback();
        });
      } else{

        imageType = prompt('Please choose image type to export', 'png');
        if (imageType) saveAsImageByType(imageType);
        callback();
      };
    }

    if (toolbox.canvasSupported) {

      hide();

      dialogue(show);
      // imageType = prompt('Please choose image type to export, (png, jpeg)', 'png');
      // if (imageType) saveAsImageByType(imageType);

    } else{
    };
  };

  echarts.ers.toggleAverage = function() {
    var chart = this.myChart;
    var list = chart._optionRestore.series;

    for (var i = 0; i < list.length; i++) {
        if (list[i].markLine && list[i].markLine.data.length) {
            chart.delMarkLine(i, '平均值');
        } else {
            chart.addMarkLine(i, {
                data: [{
                    type: 'average',
                    name: '平均值',
                    tooltip: {
                        trigger: 'item',
                        formatter: function(x) {
                            return jade.t(x[0]) + '<br /> ' + x[1] + ' : ' + x[2];
                        }
                    },
                    itemStyle: {
                        normal: {
                            label: {
                                show: true,
                                position: 'right',
                                textStyle: {
                                    fontSize: '10'
                                },
                                formatter: function(name, x, y) {
                                    return ers.numberWithCommas(y);
                                }
                            }

                        }
                    }
                }]
            });
        }
    }
  };

  echarts.ers.toggleMaxMin = function() {
    var toolbox = this;
    var chart = this.myChart;
    var list = chart._optionRestore.series;

    var symbol = toolbox.option.toolbox.feature.toggleMaxMin.symbol || ['pin', 'emptypin'];

    if(_.isString(symbol)) symbol = [symbol, 'empty' + symbol];

    for (var i = 0; i < list.length; i++) {
        if (list[i].markPoint && list[i].markPoint.data.length) {
            chart.delMarkPoint(i, '最大值');
            chart.delMarkPoint(i, '最小值');
        } else {
            chart.addMarkPoint(i, {
                data: [{
                    type: 'max',
                    name: '最大值',
                    tooltip: {
                        trigger: 'item',
                        formatter: function(x) {
                            return jade.t(x[0]) + '<br /> ' + x[1] + ' : ' + x[2];
                        }
                    },
                    symbol: symbol[0],
                    symbolSize: 10,
                    itemStyle: {
                        normal: {
                            label: {
                                show: true,
                                position: 'right',
                                textStyle: {
                                    fontSize: '10'
                                },
                                formatter: function(name, x, y) {
                                    return ers.numberWithCommas(y);
                                }
                            }
                        }
                    }


                }, {
                    type: 'min',
                    name: '最小值',
                    tooltip: {
                        trigger: 'item',
                        formatter: function(x) {
                            return jade.t(x[0]) + '<br /> ' + x[1] + ' : ' + x[2];
                        }
                    },
                    symbol: symbol[1],
                    symbolSize: 10,
                    itemStyle: {
                        normal: {
                            label: {
                                show: true,
                                position: 'right',
                                textStyle: {
                                    fontSize: '10'
                                },
                                formatter: function(name, x, y) {
                                    return ers.numberWithCommas(y);
                                }
                            }
                        }
                    }

                }]
            });
        }
    }
  };

  echarts.ers.toggleScale = function() {
    var myChart = this.myChart;
    if (myChart._timeline) {

    } else{
      var option = {};
      var xAxis = myChart._optionRestore.xAxis;
      var yAxis = myChart._optionRestore.yAxis;
      if (xAxis) {
        option.xAxis = _.map(xAxis, function(_xAxis) {
          if (_xAxis.type === 'value') _xAxis.scale = !_xAxis.scale;
          return _xAxis;
        })
      };
      if (yAxis) {
        option.yAxis = _.map(yAxis, function(_yAxis) {
          if (_yAxis.type === 'value') _yAxis.scale = !_yAxis.scale;
          return _yAxis;
        })
      };
      myChart.setOption(option);
    };
  };
})(echarts);
