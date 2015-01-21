exports.methods = [
  name: '性別比'
  func: (rawdatas) ->

,
  name: '平均值'
  func: (rawdatas) ->
,
  name: '最大值'
,
  name: '最小值'
,
  name: '環比變幅'
,
  name: '環比差值'
,
  name: '平均變幅'
,
  name: '同比變幅'
,
  name: '同比差值'
]

exports.method_modes = [
  mode: '趨勢'
  method: ['平均值', '極值', '環比', '同比', '平均變幅']

]

# (1)趨勢：平均值、極值、環比、(同比)、平均變幅

# (2)性別：性別比、平均值、極值、環比、(同比)、平均變幅

# 年齡1：平均值、極值

# 年齡2：性別比、平均值、極值

# 性別比：Sex Ratio
# 平均值：Average
# 極值：Extremum
# 最大值：Maximum
# 最小值：Minimum
# 環比：Compared with Previous Period
# 環比變幅：Previous Period Variance
# 環比差值：Pervious Period Difference
# 平均變幅：Average Change

# 同比：Compared with Same Period
# 同比變幅：Same Period Variance
# 同比差值：Same Period Difference
