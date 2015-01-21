config = require 'config'

Links = require 'models/links'
links = require './links'

HeaderView = require './header_view'

module.exports = class HeaderNode extends Backbone.Node

  requires:
    'router': 'router'
    'me': 'me'

  initialize: ->
    @collection = new Links
    @header_view = new HeaderView {@collection}
    $('#header_view').html @header_view.render().el
    @collection.set links

  ready: ->
    @listenTo @router, 'route', @activeLink
    @profile @me

  activeLink: (selector) ->
    link = @collection.findWhere {selector}
    link and link.trigger 'model:active'

  profile: (me) ->
    me.trigger 'checkin', (access_token) =>
      url = config.oauth.baseUrl + '/user/profile?access_token=' + access_token
      @header_view.model = me
      @header_view.setUrl url
