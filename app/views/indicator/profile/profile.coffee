Profiles = require 'models/profiles'

load_profiles = new Profiles # profiles collection for load a profile from server by indicator_id

save_profiles = new Profiles # profiles collection for save a profile to server by indicator_id

{ parser, stringifier, parser3 } = require './parser'


component = require './component'

# piper has to be loaded after parse because of _.pathGet
piper = require './piper'

# test require promise_piper
promise_piper = require './promise_piper'

# variables collection
matrix = require './matrix'

module.exports = ->

  profile =
    indicator_id: null
    profile:
      variables: []
      components: []

  _.extend {}, Backbone.Events,


    # left data operation
    addData: (data, name) ->

    deleteData: (name) ->

    editData: (name) ->

    saveVariables: (variables) ->
      profile.profile.variables = variables
      @trigger 'profile:variables:reset'

    # right component options

    saveActiveOption: (option) ->
      @trigger 'preview_view:show:component', option

    # center component manage
    sortComponent: ->

    removeComponent: ->

    addComponent: (option) ->
      @trigger 'profile:active', option

    deactiveComponent: ->
      @trigger 'profile:deactive'

    showComponent: (option = '', _variables) ->
      return if _.isEmpty option
      self = this
      promise_piper _variables, (variables) ->
        # option_string = stringifier option
        # return if _.isEmpty option_string
        # option = parser option_string, variables
        option = parser3 option, variables
        self.trigger 'show:component', option

    renderComponent: ($el, option) ->
      component.render $el, option

    disposeParent: ($parent) ->
      component.disposeParent $parent

    renderComponents: ($parent, _profile, editable = false) ->
      if _.isObject(_profile) and _profile.profile
        @_renderComponents $parent, _profile, editable
      else
        component.disposeParent $parent
        $parent.html _profile

    _renderComponents: ($parent, _profile, editable = false) ->
      { variables, components } = _profile.profile
      components = components.reverse()
      @trigger 'render:start'
      if editable and not components.length
        component.disposeParent $parent
        return $parent.html $('<li>', text: 'add your components here').addClass('placeholder')
      promise_piper variables, (_variables) ->
        component.disposeParent $parent
        $parent.empty()
        $$variables = matrix variables
        _.each components, (_component) ->
          # get option
          # option_string = stringifier _component
          # option = parser option_string, _variables
          option = parser3 _component, _variables
          option.$$variables = $$variables
          # get $el
          $el = $('<li>')
          .addClass "component"
          .prependTo $parent
          .data 'component-option', _component

          if editable
            $el
            .on "mouseenter", ->
              return if $('button.remove-component', this).length
              $("<button>", text: "x").addClass("remove-component").appendTo $(this)
            .on "click", "button.remove-component", ->
              $li = $(this).parent()
              $li.trigger "deactive:component"  if $li.hasClass("active-component")
              $li.children().each -> $(this).trigger 'dispose:component'
              $li.remove()

              $parent.html $('<li>', text: 'add your components here').addClass('placeholder') unless $parent.children().length
            .on "mouseleave", -> $("button.remove-component", this).remove()

          component.render $el, option

    saveComponents: (components) ->
      components = _.compact components
      profile.profile.components = components

    # connect to server

    # generate profile as pure json
    toJSON: ->

    load: (indicator_id) ->
      unless indicator_id
        @trigger 'profile:found',
          indicator_id: null
          profile:
            variables: []
            components: []
        return @trigger 'reset'

      load_profiles
      .fetch data: { indicator_id }
      .done (results) =>
        if _.isEmpty results
          @trigger 'profile:found',
            indicator_id: null
            profile:
              variables: []
              components: []
        else
          @trigger 'profile:found', results[0]

    # save profile to server
    save: ->
      @trigger 'prepare:profile'
      isValid = @_checkValid()
      return alert 'please make sure indicator, variables, components not empty' unless isValid
      console.log profile
      @save2server()

    save2server: ->
      self = this
      { indicator_id } = profile
      save_profiles
      .fetch data: { indicator_id }, reset: true
      .then ->
        if save_profiles.length
          return unless confirm 'this indicator already has a profile, sure to overwrite?'
          already_exist_profile = save_profiles.first()
          already_exist_profile.save profile, success: (data) -> self.trigger 'profile:update', data
        else
          return unless confirm 'sure to create a new profile for this indicator?'
          save_profiles.create profile, success: (data) -> self.trigger 'profile:create', data

      # profiles.create profile

    _checkValid: ->
      profile.indicator_id and profile.profile.variables.length and profile.profile.components.length

    # save and connect with indicator
    getIndicator: ->
      profile.indicator_id

    setIndicatorId: (indicator_id) ->
      profile.indicator_id = indicator_id

      this
