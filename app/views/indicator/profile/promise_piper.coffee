###
  there is a promise tree,
  arguments are promises,
  function should also return promises;
###
methods = require './methods'

$when = _.bind $.when, $

# check is {value} is a jquery promise
isPromise = (value) ->
  return false unless value
  return false  if typeof value.then isnt "function"
  promiseThenSrc = String($.Deferred().then)
  valueThenSrc = String(value.then)
  promiseThenSrc is valueThenSrc


# given a function, and args, args maybe promises too, return a promise
p1 = (fn, args...) ->
  defer = $.Deferred()
  $
  .when args...
  .then (_args...) ->
    if fn
      try
        result = fn _args...
      catch e
        alert 'Error: ' + fn.fname + ':' + _args.join()
        console.log e

      if isPromise result then result else $.when result
    else
      $.when _args...
  .then -> defer.resolve.apply defer, arguments
  .fail -> defer.reject.apply defer, arguments

  defer.promise()


# test_p1_fn = (x) ->
#   console.log 'x1=', x
#   defer = $.Deferred()

#   setTimeout (-> defer.resolve x + 1), 1000

#   defer.promise()

# test_p1_fn.isPromise = true

# test_p1_arg = $.when 2


# test_p1_fn1 = (x, y) ->
#   console.log 'x1=', x
#   console.log 'x2=', y
#   defer = $.Deferred()

#   setTimeout (-> defer.resolve x + y), 1000

#   defer.promise()

# test_p1_fn1.isPromise = true

# test_p1_arg1 = $.when 20


# p1(test_p1_fn, test_p1_arg)
# .then (y) -> console.log y


# p2 = (fn) -> (args...) ->
#   defer = $.Deferred()
#   $
#   .when(args...)
#   .then (_args...) -> (if fn and fn.isPromise then fn else $when) _args...
#   .then (_args...) -> defer.resolve fn _args...
#   .fail -> defer.reject.apply defer, arguments

#   defer.promise()

# this function is chain of p1,
# the previous result will be passed as the first argument for the next function
p3 = (pipe_array = []) ->
  result = $.when()
  _.each pipe_array, (pipe) ->
    [fn, args...] = pipe
    result = result.then (last_result) ->
      args.unshift last_result if last_result
      p1 fn, args...

  result

# p3([[test_p1_fn, test_p1_arg], [test_p1_fn1, test_p1_arg1]])
# .then (y) ->
#   console.log 'x1+x2=', y

pipeSplitter = /\s+\|\s+/

argSplitter = /\s*:\s*/

pathSplitter = '.'

# you can get 'f.x' at 1 from {f: {x: 1}}
getValueByPath = (obj, path = '') ->
  return obj if path is ''
  oldPath = path
  path = path.split pathSplitter
  result = obj
  for p in path
    result = result[p]
    return oldPath unless result

  result

# find a variable from variables
find = (name, variables = [{}]) ->
  _.find variables, (variable) -> variable.name is name


# find a deep attribute value from a promise
path = (path_string = '', variables = [{}]) ->
  path_array = path_string.split pathSplitter
  return $.when() unless path_array.length

  variable = find path_array[0], variables
  return $.when path_string unless variable
  variable = pp variable, variables
  childPath = path_array.slice(1).join(pathSplitter)

  $
  .when variable.promise
  .then (obj) -> $.when obj and getValueByPath(obj, childPath)

# variables1 = [
#   name: 'x'
#   promise: methods.getIndicator()

# ]

# path 'x', variables1
# .then (x) -> console.log x

# need trim a tring
# refer Polifill from https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/Trim
unless String::trim
  String::trim = ->
    @replace /^[\s\xA0]+|[\s\xA0]+$/g, ""

# generate a promise from a pipe_string
ps = (pipe_string, variables = [{}]) ->
  pipe_string = 'identity:' + pipe_string.trim()

  pipe_array = pipe_string
    .split pipeSplitter
    .map (arg_string) -> arg_string.split argSplitter

  pipe_array = _.map pipe_array, (pipe) ->
    [fn, args...] = pipe
    fname = fn
    fn = methods[fn]
    fn.fname = fname
    args = _.map args, (arg) -> path arg, variables
    [fn, args...]

  p3 pipe_array

# add a promise attribute to variable
pp = (variable, variables = [{}]) ->
  return variable if variable.promise
  variable.promise = ps variable.type, variables
  variable

# iterate all variables to have a promise attribute
p4 = (variables = [{}]) ->
  _.map variables, (variable) -> pp variable, variables


# when all variable datas are ready, callback will be called
pa = (variables = [{}], callback = ->) ->
  variables = p4 variables
  promises = _.map variables, (variable) -> variable.promise
  $
  .when promises...
  .then callback

pb = (variables, callback = ->) ->
  names = _.pluck variables, 'name'
  pa variables, (results...) -> callback _.object names, results

# variables =
#   year_value: [
#     year: 2011
#     value: 10
#   ,
#     year: 2022
#     value: 20
#   ]

# pipe_string = 'year_value | min:year'

# variables2 = [
#   name: 'xyz'
#   type: '1'
# ,
#   name: 'indicator1'
#   type: 'xyz | getIndicator'
# ,
#   name: 'minYear'
#   type: 'indicator1 | min:year'
# ]

# pa variables2, (results...) ->
#   console.log results...

# pb variables2, (x) -> console.log x

module.exports = pb
