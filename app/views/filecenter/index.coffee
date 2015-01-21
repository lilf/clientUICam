AboutusView = require './aboutus_view'
module.exports = class FooterNode extends Backbone.Node

  initialize: ->
    @aboutus_view = new AboutusView
    $('#child_block_view').html @aboutus_view.render().el
