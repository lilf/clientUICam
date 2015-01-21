interpolate = /\{\{(.+?)\}\}/g
pathSplitter = '.'

another_interpolate = /^\s*\{\{(.+?)\}\}\s*$/g

_.templateSettings = interpolate: /\{\{(.+?)\}\}/g

getValueByPath = (obj, path) ->
  oldPath = path
  path = path.split pathSplitter
  result = obj
  for p in path
    result = result[p]
    return oldPath unless result

  result

_.mixin pathGet: (obj, path) -> getValueByPath obj, path

# module.exports = abc = (json_string, variables) ->

#   JSON.parse json_string, (key, value) ->

#     if interpolate.test value
#       match = value.match interpolate
#       if another_interpolate.test value
#         match2 = value.match another_interpolate
#         path = match2[0].slice 2, -2
#         return getValueByPath variables, path
#       else
#         template = _.template value
#         return template variables
#     else
#       value

exports.stringifier  = stringifier = (obj) ->
  JSON.stringify obj, (key, value) ->
    return value.toString()  if value instanceof Function or typeof value is "function"
    return "_PxEgEr_" + value  if value instanceof RegExp
    value


exports.parser = parser = (str, variables, date2obj) ->
  iso8061 = (if date2obj then /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2}(?:\.\d*)?)Z$/ else false)
  JSON.parse str, (key, value) ->
    if interpolate.test value
      match = value.match interpolate
      if another_interpolate.test value
        match2 = value.match another_interpolate
        path = match2[0].slice 2, -2
        return getValueByPath variables, path
      else
        template = _.template value
        return template variables
    else
      prefix = undefined
      return value  unless typeof value is "string"
      return value  if value.length < 8
      prefix = value.substring(0, 8)
      return new Date(value)  if iso8061 and value.match(iso8061)
      return eval("(" + value + ")")  if prefix is "function"
      return eval(value.slice(8))  if prefix is "_PxEgEr_"
      value


iterator_json = (json, func) ->
  switch
    when _.isDate json
      func json, 'date'

    when _.isFunction json
      func json, 'function'

    when _.isArray json
      return json if json.$$no_further
      _.map json, (item) -> iterator_json item, func

    when (_.isObject(json) and json.constructor is Object)
      for own key, value of json
        json[key] = iterator_json value, func
      json

    when _.isBoolean json
      func json, 'boolean'

    when _.isString json
      func json, 'string'

    else
      func json, 'other'

# test iterator_json

# window.a = a =
#   name: 'text'
#   template: '{{fasdfas}}'
#   kkk: true
#   z: (->
#     zrColor = zrender.tool.color
#     zrColor.getLinearGradient 0, 0, 1000, 0, [
#       [
#         0
#         "rgba(255,0,0,0.8)"
#       ]
#       [
#         0.8
#         "rgba(255,255,0,0.8)"
#       ]
#     ]
#   )()
#   child:
#     cc: 'x'
#     d: 1
#     kk:
#       m: 'y'
#       n:
#         i: 2
#     ee: ->

# iterator_json a, (x, type) ->
#   switch type
#     when 'string'
#       x + 1
#     when 'boolean'
#       false
#     else
#       x

# console.log a

exports.parser3 = parser3 = (json_string, variables) ->
  try
    json = evaluate json_string, variables
  catch e
    alert 'error happened: ' + e.message

  parser2 json, variables

  json

no_further = (f) ->
  data = f()
  data.$$no_further = true
  data

exports.evaluate = evaluate = (json_string, variables) ->

  (new Function('$vars', '$set', 'return ' + json_string))(variables, no_further)


exports.parser2 = parser2 = (json, variables) ->

  iterator_json json, (value, type) ->
    switch type
      when 'string'
        if interpolate.test value
          match = value.match interpolate
          if another_interpolate.test value
            match2 = value.match another_interpolate
            path = match2[0].slice 2, -2
            return getValueByPath variables, path
          else
            template = _.template value
            return template variables
        else
          value
      else
        value
# may be we should write a test

# a =
#   "type": "text",
#   "template": "{{fullname.x}}"

# v =
#   name: 'cp'
#   value: 1
#   fullname:
#     x: 'good cp'

# js = JSON.stringify a

# console.log abc js, v

# js = stringifier a
# console.log parser js, v
