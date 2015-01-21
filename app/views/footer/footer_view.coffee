module.exports = class FooterView extends Backbone.View

  template: require './templates/footer'

  className: 'uk-margin-top'

  events:
    # 'inview .detect-fixed-bottom': 'inview'
    'click #about_us': 'show'

  render: ->
    @$el.html @template()
    @$detect = @$('.detect-fixed-bottom')
    @$fix = @$('.to-fixed-bottom')

    this

  inview: (e, isInView) ->
    if isInView then @$fix.slideDown() else @$fix.slideUp()
    scroll = if $(window).height() - $('body').height() < 0 then false else true
    @$fix.toggleClass 'fix-bottom', isInView and scroll

  show: (e) ->
    e.preventDefault()
    $('#div_txt').show()
