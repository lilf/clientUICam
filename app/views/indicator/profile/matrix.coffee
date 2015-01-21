# test require promise_piper
promise_piper = require './promise_piper'

getRelatedVariables = (variable, $$variables) ->
  { name, promise } = variable
  re = new RegExp '^\\s*' + name + '\\s*$'
  found = _.filter $$variables, (_variable) -> re.test _variable.type.split(/\s+\|\s+/, 1)[0]?.split('.', 1)
  deep = _.map found, (_variable) -> results = getRelatedVariables _variable, $$variables

  _.flatten [found, deep]

module.exports = matrix = ($variables) ->

  _.extend {}, Backbone.Events,

    drink: (fn) ->
      promise_piper $variables, fn

    eat: (variable) ->
      [ new_variables, related_names ] = @getNewVariableList variable
      promise_piper new_variables, (_variables) =>
        for key, value of _variables when _.contains related_names, key
          @trigger 'variable', key, value, _variables

    getNewVariableList2: (variable) ->
      { name, promise } = variable
      re = new RegExp '^\s*' + name

      [related, others] = _.chain $variables
        .reject (_variable) -> _variable.name is name
        .partition (_variable) -> re.test _variable.type
        .value()

      related = _.map related, (_variable) -> _.omit _variable, 'promise'
      related_names = _.map related, (_variable) -> _variable.name
      new_variables = _.flatten [related, variable, others]
      [new_variables, related_names]

    getNewVariableList: (variable) ->
      related = getRelatedVariables variable, $variables
      others = _.without $variables, related...

      related = _.map related, (_variable) -> _.omit _variable, 'promise'
      related_names = _.map related, (_variable) -> _variable.name
      new_variables = _.flatten [related, variable, others]
      [new_variables, related_names]

# test matrix

# $$var = [
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
#   {
#     name: 'ddd'
#     type: 'ccc'
#   }
#   {
#     name: 'eee'
#     type: 'ddd'
#   }
#   {
#     name: 'xxx'
#     type: 'ddd'
#   }
# ]

# m = matrix $$var



# console.log getRelatedVariables {name: 'ccc'}, $$var
# console.log m.getNewVariableList {name: 'ccc'}

# console.log m.getRelatedVariables {name: 'ccc'}
