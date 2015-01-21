ProfileView = require './profile_view'

profileGetter = require './profile'

module.exports = class ProfileNode extends Backbone.Node

  requires:
    indicators: 'indicators'

  initialize: ->
    @profile = profileGetter()
    @profile_view = new ProfileView
    $('#indicator_profile_view').html @profile_view.render().el

    @listenTo @profile, 'profile:found', @found
    @listenTo @profile, 'render:start', @start

  ready: ->
    @listenTo @indicators, 'add:item', @addItem

  addItem: (indicator_id) ->
    @profile.load indicator_id

  found: (_profile) ->
    if _profile.profile.components.length
      @profile.renderComponents $('#indicator_profile_view'), _profile
    else
      @profile.renderComponents $('#indicator_profile_view'), '<div style="font-size:20px;"><i class="uk-icon-exclamation-triangle"></i><span>暫無數據 <a href="#">點擊返回首頁</a></span></div>'

  start: ->
    @profile.renderComponents $('#indicator_profile_view'), @profile_view.el
