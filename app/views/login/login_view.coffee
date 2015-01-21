config = require 'config'

module.exports = class LoginView extends Backbone.View

  template: require './templates/login'

  success: require './templates/success'

  events:
    'click button.login': 'login'
    'click button.reset': 'resetForm'

  render: ->
    @$el.html @template()

    this

  login: (e) ->
    e.preventDefault()
    {email, password} = @$el.toObject()
    # console.log email, password

    return @shakeForm() if _.isEmpty(email) or _.isEmpty(password)

    url = config.oauth.baseUrl + '/oauth/signin'
    param =
      email: email
      password: password
      client_id: config.oauth.clientId

    $
    .post url, param
    .done (data) =>
      $('#app').html @success()
      @model.login data?.access_token
    .fail (jqXHR) =>
      console.log jqXHR
      @shakeForm()
      # alertify.alert '登陸失敗'

  resetForm: (e) ->
    e.preventDefault()
    @$('form').get(0).reset()

  shakeForm: ->
    l = 20
    i = 0

    while i < 10
      @$('form').animate
        "margin-left": "+=" + (l = -l) + "px"
      , 50
      i++
