config = require 'config'

LinkView = require './link_view'

module.exports = class HeaderView extends Backbone.View

  template: require './templates/header'

  profile: require './templates/profile'

  events:
    'click #my-id-header-modal button.change-password': 'changePassowrd'
    'keyup #my-id-header-modal input[name=password2]': 'checkMatchPassword'
    'click #my-id-header-modal button.cancel': 'resetForm'

  initialize: ->
    @listenTo @collection, 'add', @addLink

  render: ->
    @$el.html @template()
    @$list = @$ '.uk-navbar-link-left'

    this

  addLink: (model) ->
    link_view = new LinkView {model}
    @$list.append link_view.render().el

  setUrl: (url) ->
    # @$('#my-id-header-modal p').html @profile {url}
    @$('#my-id-header-modal p').html @profile @model.toJSON()


  changePassowrd: (e) ->
    e.preventDefault()
    {password, password2, lang} = @$('#my-id-header-modal p').toObject()
    @resetForm()

    return @shakeForm() if _.isEmpty(password) or _.isEmpty(password2)
    return @shakeForm() if password isnt password2

    username = @model.get 'username'
    json = newPassword: password, lang: lang, username: username

    url = config.oauth.baseUrl + '/user/password'


    $
    .ajax
      access_token: true
      url: url
      type: 'POST'
      data: json
    .done =>
      @showStatusText true

    .fail =>
      @showStatusText false

  resetForm: (e) ->
    e?.preventDefault()
    @$('#my-id-header-modal p form').get(0).reset()
    @$('#my-id-header-modal p i').addClass 'uk-hidden'

  checkMatchPassword: ->

    $elment = @$('#my-id-header-modal p')
    {password, password2, lang} = $elment.toObject()

    return if _.isEmpty(password) or _.isEmpty(password2)
    $elment.find('i.uk-icon-check.uk-text-success').toggleClass 'uk-hidden', password isnt password2
    $elment.find('i.uk-icon-times.uk-text-danger').toggleClass 'uk-hidden', password is password2


  showStatusText: (ok = true) ->
    success = @$('span.uk-text-success.result-status')
    danger = @$('span.uk-text-danger.result-status')

    if ok
      success.show().fadeOut(5000)
      danger.hide()
    else
      danger.show().fadeOut(5000)
      success.hide()

  shakeForm: ->
    l = 20
    i = 0

    while i < 10
      @$('#my-id-header-modal p form').animate
        "margin-left": "+=" + (l = -l) + "px"
      , 50
      i++
