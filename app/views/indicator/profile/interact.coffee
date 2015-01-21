
module.exports = interact = (view, option) ->
  { events, variables, $$variables } = option
  return view unless $$variables # called from save option by single component

  $$variables.listenTo view, 'dispose', ->
    # console.log '$$variables.stopListening view'
    option.$$variables = null
    $$variables.stopListening view

  $$variables.listenTo view, 'event', (event_name, args...) ->
    func = events?[event_name]
    return unless func
    # console.log event_name, 'event'
    $$variables.drink (_variables) ->
      # { name, promise } = func view, _variables, args...
      # promise = $.when promise
      # $$variables.eat { name, promise}

      variables_json = func view, _variables, args...
      return unless variables_json and _.isObject(variables_json)
      variables_json = [variables_json] unless _.isArray variables_json
      for variable in variables_json
        { name, promise} = variable
        promise = $.when promise
        $$variables.eat { name, promise}

  view.listenTo $$variables, 'variable', (var_name, var_value, args...) ->
    func = variables?[var_name]
    return unless func
    # console.log var_name, 'variable'
    $$variables.drink (_variables) ->
      old_value = _variables[var_name]
      func view, var_value, old_value, args...

  view


# test interact
# matrix = require './matrix'

# $$var = matrix [
#   {
#     name: 'aaa'
#     type: 'dog | log'
#   }
#   {
#     name: 'bbb'
#     type: 'cat'
#   }
#   {
#     name: 'ccc'
#     type: 'bbb'
#   }
# ]

# later_value = ->
#   defer = $.Deferred()
#   setTimeout (-> defer.resolve 'pig'), 2000
#   defer.promise()

# option1 =
#   type: 'text'
#   events:
#     hello: ->
#       console.log 'event', arguments...
#       name: 'bbb'
#       promise: later_value() # 'pig'
#   $$variables: $$var

# option2 =
#   type: 'chart'
#   variables:
#     aaa: -> console.log 'variable', arguments...
#     ccc: -> console.log 'variable', arguments...
#   $$variables: $$var

# view1 = new Backbone.View

# view2 = new Backbone.View

# interact view1, option1
# interact view2, option2

# view1.trigger 'event', 'hello'
