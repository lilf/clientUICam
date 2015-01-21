config = require 'config'

getDataToR = (data) ->
  m = moment()
  { year, quarter, month, day } = _.pick data, 'year', 'quarter', 'month', 'day'
  m.set 'year', year
  m.set 'quarter', quarter
  m.set 'month', month
  m.set 'day', day

  addCol = {tagDate: 'year', date: m.startOf('year').format('YYYYMMDD')} if (year) and (not quarter) and (not month) and (not day)
  addCol = {tagDate: 'year_month', date: m.subtract(1, 'months').startOf('month').format('YYYYMMDD')} if year and month
  addCol = {tagDate: 'year_quarter', date: m.startOf('quarter').format('YYYYMMDD')} if year and quarter

  data = JSON.stringify data
  addCol = JSON.stringify addCol
  data = data.slice 1, data.length-1
  addCol = addCol.slice 1, addCol.length-1
  dataNew = '{' + data + ',' + addCol + '}'
  dataNew = JSON.parse dataNew

  dataNew

getDatasToR = (datas) ->
  return _.map datas, getDataToR


rserve = (name = 'sample', json, callback) ->
  callback ?= (x) -> x
  defer = $.Deferred()
  json.library = 'cam'
  $.post config.api.r + '/rserve/' + name, json, -> defer.resolve callback arguments...
  defer.promise()

monthFormate = (month) ->
  month = _.map month, (m) ->
    m = 12 if m == 0
    m = m unless m == 0
  month

# To convert the results of f_gender_ration from R to collection
# tagDate = 'year' | 'year_month' | 'year_quarter'
result_gender_ratio = (output, tagDate) ->
  # console.log tagDate, output
  year = _.map output.time, (t) -> (moment t).year()
  month = _.map output.time, (t) -> (moment t).add(1, 'months').month()
  month = monthFormate month
  quarter = _.map output.time, (t) -> (moment t).quarter()
  gender_ratio = output.gender_ratio
  result = []
  if tagDate == 'year'
    for i in [0...gender_ratio.length]
      result.push {
        gender_ratio: gender_ratio[i],
        year: year[i]
      }
  if tagDate == 'year_month'
    for i in [0...gender_ratio.length]
      result.push {
        gender_ratio: gender_ratio[i],
        year: year[i],
        month: month[i]
      }
  if tagDate == 'year_quarter'
    for i in [0...gender_ratio.length]
      result.push {
        gender_ratio: gender_ratio[i],
        year: year[i],
        quarter: quarter[i]
      }
  # console.log result
  result

#test 'f_gender_ratio'
# outputR_gender_ration = {
#   gender_ratio: [ 105.62, 105.76, 106, 106.14, 106.38 ],
#   OK: true,
#   time: [ "1970-01-01",  "1971-01-01", "1972-01-01", "1973-11-01", "1974-12-01" ]
# }
#test result_gender_ratio
# result_gender_ratio outputR_gender_ration

#To convert the results of f_growth_of_year from R to collection
# tagDate = year
result_grwoth_of_year = (output, tagDate) ->
  # console.log tagDate
  # console.log output
  result = []
  if output.group is undefined
    year = [
      (moment output.start_time).year(),
      (moment output.end_time).year()
    ]
    month = [
      (moment output.start_time).add(1, 'months').month(),
      (moment output.end_time).add(1, 'months').month()
    ]
    month = monthFormate month
    quarter = [
      (moment output.start_time).quarter(),
      (moment output.end_time).quarter()
    ]
    value = output.growth_of_year
    if tagDate == 'year'
      result.push {
        year: year
        value: value
      }
    if tagDate == 'year_month'
      result.push {
        year: year
        month: month
        value: value
      }
    if tagDate == 'year_quarter'
      result.push {
        year: year
        quarter: quarter
        value: value
      }
  else
    end_year = _.map output.end_time, (t) -> (moment t).year()
    end_month = _.map output.end_time, (t) -> (moment t).add(1, 'months').month()
    end_month = monthFormate end_month
    end_quarter = _.map output.end_time, (t) -> (moment t).quarter()
    start_year = _.map output.start_time, (t) -> (moment t).year()
    start_month = _.map output.start_time, (t) -> (moment t).add(1, 'months').month()
    start_month = monthFormate start_month
    start_quarter = _.map output.start_time, (t) -> (moment t).quarter()
    value = output.growth_of_year
    group = output.group
    if tagDate == 'year'
      for i in [0...value.length]
        result.push {
          year: [start_year[i], end_year[i]],
          group: group[i],
          value: value[i]
        }
    if tagDate == 'year_month'
      for i in [0...value.length]
        result.push {
            year: [start_year[i], end_year[i]],
            month: [start_month[i], end_month[i]],
            group: group[i],
            value: value[i]
        }
    if tagDate == 'year_quarter'
      for i in [0...value.length]
        result.push {
          year: [start_year[i], end_year[i]],
          quarter: [start_quarter[i], end_quarter[i]],
          value: value[i]
        }
  # console.log result
  result

#test 'f_growth_of_year'
#output based on group
# outputR_growth_of_year_group = {
#   end_time: [ "2013-12-01", "2013-01-01", "2013-11-01" ],
#   group: [ "F", "M", "MF"],
#   OK: true,
#   start_time: [ "1970-01-01", "1970-01-01", "1970-01-01"],
#   growth_of_year: [ 2.2315, 1.9679, 2.0997 ]
#   }
# #output all
# outputR_growth_of_year = {
#   OK: true,
#   growth_of_year: 0.6844,
#   start_time: "1970-01-01",
#   end_time: "2013-12-01"
# }
# result_grwoth_of_year outputR_growth_of_year

#To convert the results of f_year_on_year from R to collection
# tagDate = 'year_month'
result_year_on_year = (output, tagDate) ->
  result = []
  if output.group is undefined
    year = _.map output.time, (t) -> (moment t).year()
    month = _.map output.time, (t) -> (moment t).add(1, 'months').month()
    month = monthFormate month
    quarter = _.map output.time, (t) -> (moment t).quarter()
    value = output.value_year_on_year
    if tagDate == 'year'
      for i in [0...value.length]
        result.push {
          year: year[i],
          value: value[i]
        }
    if tagDate == 'year_month'
      for i in [0...value.length]
        result.push {
          year: year[i],
          month: month[i],
          value: value[i]
        }
    if tagDate == 'year_quarter'
      for i in [0...value.length]
        result.push {
          year: year[i],
          quarter: quarter[i],
          value: value[i]
        }
  else
    year = _.map output.time, (t) -> (moment t).year()
    month = _.map output.time, (t) -> (moment t).add(1, 'months').month()
    month = monthFormate month
    quarter = _.map output.time, (t) -> (moment t).quarter()
    group = output.group
    value = output.value_year_on_year
    if tagDate == 'year'
      for i in [0...value.length]
        result.push {
          year: year[i],
          group: group[i],
          value: value[i]
        }
    if tagDate == 'year_month'
      for i in [0...value.length]
        result.push {
          year: year[i],
          month: month[i],
          group: group[i],
          value: value[i]
        }
    if tagDate == 'year_quarter'
      for i in [0...value.length]
        result.push {
          year: year[i],
          quarter: quarter[i],
          group: group[i],
          value: value[i]
        }
  # console.log result
  result

#output based on group
# outputR_year_on_year_group = {
#   group: [ "F", "M", "F", "M" ],
#   OK: true,
#   time: [ "1995-01-01", "1995-11-01", "1995-03-01", "1995-12-01" ],
#   value_year_on_year: [ 1.0602, 2.8741, 1.5596, 1.4817 ]
# }
# # console.log outputR_year_on_year_group
# #output all
# outputR_year_on_year = {
#   OK: true,
#   time: [ "1995-02-01", "1995-12-01" ],
#   value_year_on_year: [ 3.9148, 2.6105 ]
# }
# result_year_on_year outputR_year_on_year

#To convert the results of f_year_on_year_dif from R to collection
# tagDate = 'year_month'
result_year_on_year_dif = (output, tagDate) ->
  result = []
  if output.group is undefined
    year = _.map output.time, (t) -> (moment t).year()
    month = _.map output.time, (t) -> (moment t).add(1, 'months').month()
    month = monthFormate month
    quarter = _.map output.time, (t) -> (moment t).quarter()
    value = output.value_year_on_year_dif
    if tagDate == 'year'
      for i in [0...value.length]
        result.push {
          year: year[i],
          value: value[i]
        }
    if tagDate == 'year_month'
      for i in [0...value.length]
        result.push {
          year: year[i],
          month: month[i],
          value: value[i]
        }
    if tagDate == 'year_quarter'
      for i in [0...value.length]
        result.push {
          year: year[i],
          quarter: quarter[i],
          value: value[i]
        }
  else
    year = _.map output.time, (t) -> (moment t).year()
    month = _.map output.time, (t) -> (moment t).add(1, 'months').month()
    month = monthFormate month
    quarter = _.map output.time, (t) -> (moment t).quarter()
    group = output.group
    value = output.value_year_on_year_dif
    if tagDate == 'year'
      for i in [0...value.length]
        result.push {
          year: year[i],
          group: group[i],
          value: value[i]
        }
    if tagDate == 'year_month'
      for i in [0...value.length]
        result.push {
          year: year[i],
          month: month[i],
          group: group[i],
          value: value[i]
        }
    if tagDate == 'year_quarter'
      for i in [0...value.length]
        result.push {
          year: year[i],
          quarter: quarter[i],
          group: group[i],
          value: value[i]
        }
  # console.log result
  result

#test result_year_on_year_dif
# output based on group
# outputR_year_on_year_dif_group = {
#   group: [ "F", "M", "F", "M" ],
#   OK: true,
#   time: [ "1995-02-01", "1995-02-01", "1995-03-01", "1995-12-01" ],
#   value_year_on_year_dif: [ 4400, 11600, 6700, 6300 ]
# }
# #output all
# outputR_year_on_year_dif = {
#   OK: true,
#   time: [ "1995-02-01", "1995-12-01" ],
#   value_year_on_year_dif: [ 15800, 2.6105 ]
# }
# result_year_on_year_dif outputR_year_on_year_dif

#To convert the results of f_ring_ratio from R to collection
#tagDate = 'year_month'
result_ring_ratio = (output, tagDate) ->
  result = []
  # tagDate = "year_month"
  if output.group is undefined
    year = _.map output.time, (t) -> (moment t).year()
    month = _.map output.time, (t) -> (moment t).add(1, 'months').month()
    month = monthFormate month
    quarter = _.map output.time, (t) -> (moment t).quarter()
    value = output.ring_ratio
    if tagDate == 'year'
      for i in [0...value.length]
        result.push {
          year: year[i],
          value: value[i]
        }
    if tagDate == 'year_month'
      for i in [0...value.length]
        result.push {
          year: year[i],
          month: month[i],
          value: value[i]
        }
    if tagDate == 'year_quarter'
      for i in [0...value.length]
        result.push {
          year: year[i],
          quarter: quarter[i],
          value: value[i]
        }
  else
    year = _.map output.time, (t) -> (moment t).year()
    month = _.map output.time, (t) -> (moment t).add(1, 'months').month()
    month = monthFormate month
    quarter = _.map output.time, (t) -> (moment t).quarter()
    group = output.group
    value = output.ring_ratio
    if tagDate == 'year'
      for i in [0...value.length]
        result.push {
          year: year[i],
          group: group[i],
          value: value[i]
        }
    if tagDate == 'year_month'
      for i in [0...value.length]
        result.push {
          year: year[i],
          month: month[i],
          group: group[i],
          value: value[i]
        }
    if tagDate == 'year_quarter'
      for i in [0...value.length]
        result.push {
          year: year[i],
          quarter: quarter[i],
          group: group[i],
          value: value[i]
        }
  # console.log result
  result

#test result_ring_ratio
#output based on group
# output_ring_ratio_group = {
#   group : [ "F", "F", "F", "M", "M", "M" ],
#   ring_ratio: [ 4.0296, -2.3743, 3.5181, 3.9258, -2.3518, 5.3518 ],
#   time: [ "1995-12-01", "1995-01-01", "1994-03-01", "1995-03-01", "1995-02-01", "1994-03-01" ],
#   OK: true
# }
# #output all
# output_ring_ratio = {
#   OK: true,
#   ring_ratio: [ -1.1002, 5.0819, -1.0014, -1.3641, -1.0242, 6.442, -2.747],
#   time: [ "1995-01-01", "1995-12-01", "1995-02-01", "1995-02-01", "1994-03-01", "1994-03-01", "1994-02-01"]
# }
# result_ring_ratio output_ring_ratio

#To convert the results of f_ring_dif from R to collection
#tagDate = 'year' | 'year_month'| 'year_quarter'
result_ring_dif = (output, tagDate) ->
  result = []
  if output.group is undefined
    year = _.map output.time, (t) -> (moment t).year()
    month = _.map output.time, (t) -> (moment t).add(1, 'months').month()
    month = monthFormate month
    quarter = _.map output.time, (t) -> (moment t).quarter()
    value = output.ring_dif
    if tagDate == 'year'
      for i in [0...value.length]
        result.push {
          year: year[i],
          value: value[i]
        }
    if tagDate == 'year_month'
      for i in [0...value.length]
        result.push {
          year: year[i],
          month: month[i],
          value: value[i]
        }
    if tagDate == 'year_quarter'
      for i in [0...value.length]
        result.push {
          year: year[i],
          quarter: quarter[i],
          value: value[i]
        }
  else
    year = _.map output.time, (t) -> (moment t).year()
    month = _.map output.time, (t) -> (moment t).add(1, 'months').month()
    month = monthFormate month
    quarter = _.map output.time, (t) -> (moment t).quarter()
    group = output.group
    value = output.ring_dif
    if tagDate == 'year'
      for i in [0...value.length]
        result.push {
          year: year[i],
          group: group[i],
          value: value[i]
        }
    if tagDate == 'year_month'
      for i in [0...value.length]
        result.push {
          year: year[i],
          month: month[i],
          group: group[i],
          value: value[i]
        }
    if tagDate == 'year_quarter'
      for i in [0...value.length]
        result.push {
          year: year[i],
          quarter: quarter[i],
          group: group[i],
          value: value[i]
        }
  # console.log result
  result


#output based on group
# output_ring_dif_group = {
#   group: [ "F", "F", "F", "M", "M", "M" ],
#   OK: true,
#   ring_dif:[ 16900, -10200, 14600, 16300, -10000, 21600 ],
#   time: [ "1995-01-01", "1995-12-01", "1994-03-01", "1995-03-01", "1995-02-01", "1994-03-01"]
# }
# #output all
# output_ring_dif = {
#   OK: true,
#   ring_dif: [ -4800, 21100, -4200, -5800, -4400, 26000, -11400 ],
#   time: [ "1995-12-01", "1995-01-01", "1995-02-01", "1995-02-01", "1994-03-01", "1994-03-01", "1994-02-01" ]
# }
# result_ring_dif output_ring_dif



#To convert the output of f_mean_sd fn
result_mean_sd = (output, tagDate) ->
  result = []
  if output.group is undefined
    year = [
      (moment output.start_time).year(),
      (moment output.end_time).year()
    ]
    month = [
      (moment output.start_time).add(1, 'months').month(),
      (moment output.end_time).add(1, 'months').month()
    ]
    month = monthFormate month
    quarter = [
      (moment output.start_time).quarter(),
      (moment output.end_time).quarter()
    ]
    mean = output.mean
    sd = output.sd
    if tagDate == 'year'
      result.push {
        year: year
        mean: mean
        sd: sd
      }
    if tagDate == 'year_month'
      result.push {
        year: year
        month: month
        mean: mean
        sd: sd
      }
    if tagDate == 'year_quarter'
      result.push {
        year: year
        quarter: quarter
        mean: mean
        sd: sd
      }
  else
    end_year = _.map output.end_time, (t) -> (moment t).year()
    end_month = _.map output.end_time, (t) -> (moment t).add(1, 'months').month()
    end_month = monthFormate end_month
    end_quarter = _.map output.end_time, (t) -> (moment t).quarter()
    start_year = _.map output.start_time, (t) -> (moment t).year()
    start_month = _.map output.start_time, (t) -> (moment t).add(1, 'months').month()
    start_month = monthFormate start_month
    start_quarter = _.map output.start_time, (t) -> (moment t).quarter()
    mean = output.mean
    sd = output.sd
    group = output.group
    if tagDate == 'year'
      for i in [0...group.length]
        result.push {
          year: [start_year[i], end_year[i]],
          group: group[i],
          mean: mean[i],
          sd: sd[i]
        }
    if tagDate == 'year_month'
      for i in [0...group.length]
        result.push {
            year: [start_year[i], end_year[i]],
            month: [start_month[i], end_month[i]],
            group: group[i],
            mean: mean[i],
            sd: sd[i]
        }
    if tagDate == 'year_quarter'
      for i in [0...group.length]
        result.push {
          year: [start_year[i], end_year[i]],
          quarter: [start_quarter[i], end_quarter[i]],
          group: group[i],
          mean: mean[i],
          sd: sd[i]
        }

  result

#output based on group
# output_mean_sd_group = {
#   end_time: [ "1996-12-01","1996-12-01", "1996-12-01" ],
#   group: [ "F", "M", "MF" ],
#   mean: [ 414670, 419870, 422300 ],
#   sd: [ 10810, 5116, 4101.2 ],
#   start_time: ["1994-01-01", "1994-01-01", "1995-05-01" ]}
#output all
# output_mean_sd =  {mean: 418520, sd: 7381.8, start_time: "1994-01-01", end_time: "1996-12-01"}
# result_mean_sd output_mean_sd_group



rserve_gender_ratio = (rawdatas, group, value, m, f) ->
  rawdatas = getDatasToR rawdatas
  # console.log rawdatas
  tagDate = rawdatas[0].tagDate
  o = rawdatas: rawdatas, group: group, value: value, m: m, f: f
  rserve 'f_gender_ratio', o, (results) ->
    results = result_gender_ratio results, tagDate
    # console.log results
    results

rserve_growth_of_year = (rawdatas, group, value, m, f) ->
  # console.log rawdatas
  rawdatas = getDatasToR rawdatas
  # console.log rawdatas
  tagDate = rawdatas[0].tagDate
  o = rawdatas: rawdatas, group: group, value: value, m: m, f: f
  rserve 'f_growth_of_year', o, (results) ->
    # console.log results
    results = result_grwoth_of_year results, tagDate
    # console.log results
    results


rserve_year_on_year= (rawdatas, group, value, m, f) ->
  # console.log rawdatas
  rawdatas = getDatasToR rawdatas
  tagDate = rawdatas[0].tagDate
  # console.log rawdatas, tagDate
  o = rawdatas: rawdatas, group: group, value: value, m: m, f: f
  rserve 'f_year_on_year', o, (results) ->
    # console.log results
    results = result_year_on_year results, tagDate
    # console.log results
    results

rserve_year_on_year_dif= (rawdatas, group, value, m, f) ->
  # console.log rawdatas
  rawdatas = getDatasToR rawdatas
  tagDate = rawdatas[0].tagDate
  # console.log rawdatas, tagDate
  o = rawdatas: rawdatas, group: group, value: value, m: m, f: f
  rserve 'f_year_on_year_dif', o, (results) ->
    results = result_year_on_year_dif results, tagDate
    # console.log results
    results

rserve_ring_ratio = (rawdatas, group, value, m, f) ->
  # console.log rawdatas
  rawdatas = getDatasToR rawdatas
  tagDate = rawdatas[0].tagDate
  # console.log rawdatas, tagDate
  o = rawdatas: rawdatas, group: group, value: value, m: m, f: f
  rserve 'f_ring_ratio', o, (results) ->
    results = result_ring_ratio results, tagDate
    # console.log results
    results


rserve_ring_dif = (rawdatas, group, value, m, f) ->
  # console.log rawdatas
  rawdatas = getDatasToR rawdatas
  tagDate = rawdatas[0].tagDate
  # console.log rawdatas, tagDate
  o = rawdatas: rawdatas, group: group, value: value, m: m, f: f
  rserve 'f_ring_dif', o, (results) ->
    results = result_ring_dif results, tagDate
    # console.log results
    results

rserve_mean_sd = (rawdatas, group, value, m, f) ->
  # timeScope = getTimeScope rawdatas
  rawdatas = getDatasToR rawdatas
  tagDate = rawdatas[0].tagDate
  o = rawdatas: rawdatas, group: group, value: value, m: m, f: f
  rserve 'f_mean_sd', o, (results) ->
    results = result_mean_sd results, tagDate
    # console.log results
    results


module.exports = rmethods =
  # rserve_gender_ratio 性别比
  rGenderRatio: rserve_gender_ratio
  # rserve_growth_of_year 增长率
  rGrowthOfYear: rserve_growth_of_year
  rAverageChange: rserve_growth_of_year
  # rserve_year_on_year_dif 同比差值
  rYearOnYearDiff: rserve_year_on_year_dif
  rSPV: rserve_year_on_year_dif
  # rserve_year_on_year 同比
  rYearOnYear: rserve_year_on_year
  rSPD: rserve_year_on_year
  # rserve_ring_dif 环比差值
  rserveRingDiff: rserve_ring_dif
  rPPV: rserve_ring_dif
  #rserve_ring_ratio 环比
  rRingRatio: rserve_ring_ratio
  rPPD: rserve_ring_ratio
  #rserve_mean_sd 均值与方差
  rMeanSd: rserve_mean_sd
