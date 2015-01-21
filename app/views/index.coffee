Router = require 'router'
Indicators = require 'models/indicators'
Categories = require 'models/categories'
CategoryIndicators = require 'models/category_indicators'
Bigs = require 'models/links'
bigs = require 'views/category/big/links'

module.exports = class Application extends Backbone.Node

  defines:
    router: 'router'
    indicators: 'indicators'
    categories: 'categories'
    category_indicators: 'category_indicators'
    bigs: 'bigs'

  initialize: ->
    @indicators = new Indicators
    @categories = new Categories
    @category_indicators = new CategoryIndicators
    @bigs = new Bigs

    @router = new Router
    @listenTo @router, 'route', @domainProxy 'route'

  ready: ->
    @watch 'bigs:sync'
    @watch 'categories:sync'
    @watch 'indicators:sync'
    @watch 'category_indicators:sync'

    @watch 'bigs:active_id', true
    @watch 'categories:active_id', true

    @categories.fetch()
    @indicators.fetch()
    @category_indicators.fetch()
    @bigs.add bigs
    @bigs.trigger 'sync' # mockup sync event
