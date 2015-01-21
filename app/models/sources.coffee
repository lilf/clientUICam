config = require 'config'

class Source extends Backbone.Model

  idAttribute: '_id'

module.exports = class Sources extends Backbone.Collection

  model: Source

  url: ->
    config.api.baseUrl + '/sources'

  fetch: (options = {}) ->
    options.data ?= {}
    options.data.active = true
    super options

  fetchActivedById: (_id) ->
    $.get @url(), {_id, active: true}

  fetchActivedByIds: (_ids) ->
    # _.map _ids, @fetchActivedById, this
    @fetchActivedByIn _ids

  fetchActivedByIn: (_ids) ->
    return $.when [] if _.isEmpty _ids
    url = @url() + '/search'
    $
    .post url,
      where:
        active: true
      in:
        _id: _ids
    .done (data) => @add data
