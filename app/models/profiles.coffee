config = require 'config'

class Profile extends Backbone.Model

  idAttribute: '_id'

module.exports = class Profiles extends Backbone.Collection

  model: Profile

  url: ->
    config.api.baseUrl + '/profiles'
