NewstyleView = require './newstyle_view'
module.exports = class NewstyleNode extends Backbone.Node

  initialize: ->
    @newstyle_view = new NewstyleView
    $('#main_view').html @newstyle_view.render().el
