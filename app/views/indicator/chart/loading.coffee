effect = ["spin", "bar", "ring", "whirling", "dynamicLine", "bubble"]

module.exports = (effectIndex) ->
    text : 'loading',
    effect : effect[effectIndex],
    textStyle : {
        fontSize : 20
    }

