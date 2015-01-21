module.exports =
  header: require 'views/header'
  main: Backbone.Node
  footer: require 'views/footer'
  logo: require 'views/logo'
  _aboutus: require 'views/aboutus'
  _filecenter: require 'views/filecenter'
  _help: require 'views/help'

  # indicator
  indicatorSearchbox: require 'views/indicator/searchbox'
  indicatorSummary: require 'views/indicator/summary'
  indicatorChart: require 'views/indicator/chart'
  indicatorTable: require 'views/indicator/table'
  relatedIndicator: require 'views/indicator/related'
  hotIndicator: require 'views/indicator/hot'
  indicatorList: require 'views/indicator/list'
  indicatorAnalyze: require 'views/indicator/analyze'
  indicatorBread: require 'views/indicator/bread'
  indicatorMode: require 'views/indicator/mode'
  indicatorDate: require 'views/indicator/date'
  indicatorFilter: require 'views/indicator/filter'
  indicatorMethod: require 'views/indicator/method'
  indicatorProfile: require 'views/indicator/profile'

  # category
  bigCategory: require 'views/category/big'
  categoryList: require 'views/category/list'

  application:
    node: require 'views'
    children: ['header', 'main', 'footer']

  home:
    target: 'main'
    node: require 'views/home'
    children: ['logo', 'indicatorSearchbox']

  category:
    target: 'main'
    node: require 'views/category'
    children: ['bigCategory', 'categoryList', 'indicatorList', 'logo', 'indicatorSearchbox']

  indicator:
    target: 'main'
    node: require 'views/indicator'
    # children: ['logo', 'indicatorSearchbox', 'indicatorBread', 'indicatorSummary', 'indicatorMode', 'indicatorDate', 'indicatorChart', 'indicatorTable', 'relatedIndicator', 'hotIndicator']
    children: ['logo', 'indicatorSearchbox', 'indicatorBread', 'indicatorProfile', 'relatedIndicator', 'hotIndicator']


  aboutus:
    target:'main'
    node: require 'views/layout'
    children: ['logo', 'indicatorSearchbox', '_aboutus']

  filecenter:
    target:'main'
    node: require 'views/layout'
    children: ['logo', 'indicatorSearchbox', '_filecenter']

  help:
    target:'main'
    node: require 'views/layout'
    children: ['logo', 'indicatorSearchbox', '_help']

  newstyle:
    target: 'main'
    node: require 'views/newstyle'
    children: ['logo', 'indicatorSearchbox']
