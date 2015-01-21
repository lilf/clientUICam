module.exports = class Router extends Backbone.Router

  routes:
    '': 'home'
    'home': 'home'
    'indicator': 'indicator'
    'indicator/:indicator_id': 'indicator'
    'category': 'category'
    'aboutus':'aboutus'
    'filecenter':'filecenter'
    'help':'help'
    'category/:big_id': 'category'
    'category/:big_id/:category_id': 'category'
    'newstyle': 'newstyle'

  toCategory: (big_id, category_id) ->
    return unless big_id
    path = 'category/' + big_id
    path += '/' + category_id if category_id
    @navigate path, trigger: true

  toIndicator: (indicator_id) ->
    @navigate 'indicator/' + indicator_id, trigger: true
