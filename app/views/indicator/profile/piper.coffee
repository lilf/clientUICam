methods = require './methods'

# should return a function

invokeSeries = (fns = []) ->
  _.compose fns...


piperSplitter = /\s+\|\s+/

argSplitter = /\s*:\s*/


module.exports = piper = (pipe_string, variables = {}) ->
  pipe_string = 'identity:' + pipe_string
  result = null

  pipe_array = pipe_string
    .split piperSplitter
    .map (arg_string) -> arg_string.split argSplitter

  _.each pipe_array, (pipe) ->
    [fn, args...] = pipe
    fn = methods[fn]
    args = _.map args, (arg) -> _.pathGet variables, arg
    return result unless fn
    args.unshift result if result
    result = fn args...

  result

# variables =
#   year_value: [
#     year: 2011
#     value: 10
#   ,
#     year: 2022
#     value: 20
#   ]

# pipe_string = 'year_value | min:year'

# results = piper pipe_string, variables
# console.log results
