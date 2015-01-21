config = require 'config'

Domain = require 'domain'
nodes = require 'nodes'


LoginNode = require 'views/login'

$ ->
  me = Backbone.oauth2 config.oauth

  me.on 'me:login', (me, callback) ->
    domain = new Domain nodes, false
    domain.login me
    lng = me.get 'lang'
    i18nOption =
      lng: lng
      ns: { namespaces: ['ns.special'], defaultNs: 'ns.special'} # 'ns.common',
      resGetPath: config.api.baseUrl + "/locales/resources.json?lng=__lng__&ns=__ns__",
      # debug: true
      dynamicLoad: true

    i18n.init i18nOption, ->
      jade.t = (key) -> i18n.t key
      domain.startApp()
      callback()


  me.on 'me:logout', (callback) ->
    new LoginNode me if config.oauth.local
    callback()

  me.checkin()




  # domain = new Domain nodes
  # me = new Backbone.Model username: 'chipeng'
  # me.id = -1
  # domain.login me
  # Backbone.history.start()
