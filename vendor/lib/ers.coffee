do ->
  @ers = ers = {}

  _identity = (x) -> x

  # convert time to string
  ers.timeToLocaleString = (str) -> (new Date str).toLocaleString()

  ers.timeFromString = (str) -> +(new Date str)

  # permute array // fork from d3
  ers.permute = (array, indexes) ->
      i = indexes.length
      permutes = new Array(i)
      permutes[i] = array[indexes[i]]  while i--
      permutes

  # permute matrix
  ers.permuteMatrix = (matrix, indexes) ->
    _.map matrix, (row) -> ers.permute row, indexes

  ers.numberWithCommas = (x) ->
    # return x if 0 < Math.abs(x) < 1
    # x.toString().replace /\B(?=(\d{3})+(?!\d))/g, ","
    # _.string.numberFormat x, precision

    x = (x + "").split(".")
    x[0].replace(/(\d{1,3})(?=(?:\d{3})+(?!\d))/g, "$1,") + ((if x.length > 1 then ("." + x[1]) else ""))


  ers.numberWithoutCommas = (x) ->
    if /^[0-9,.]*$/.test x
      parseFloat x.toString().replace /,/g , ''
    else
      x

  # convert collection to table

  class Table

    constructor: (@th = _identity, @td = _identity) ->

    getColumnsFromCollection: (collection) ->
      Object.keys collection[0]

    draw: (tableId, collection, columns, column, order = true) ->
      table = @getTable tableId
      table.innerHTML = ''
      return unless collection instanceof Array and collection.length >= 1
      @sortAgain collection, column, order if column

      columns ?= @getColumnsFromCollection collection
      thead = @columns2thead columns
      tbody = @collection2tbody collection
      columnLength = thead.children[0].children.length
      table.classList.remove className for className in table.classList when /^ers-table/.test className

      table.className = table.className + ' ers-table-1-' + columnLength
      table.appendChild thead
      table.appendChild tbody

    drawTable: (table, collection, columns, column, order = true) ->
      table.innerHTML = ''
      return unless collection instanceof Array and collection.length >= 1
      @sortAgain collection, column, order if column

      @columnsHeader = columns or @columnsHeader or @getColumnsFromCollection collection

      thead = @columns2thead @columnsHeader
      tbody = @collection2tbody collection, @columnsHeader
      columnLength = thead.children[0].children.length
      table.classList.remove className for className in table.classList when /^ers-table/.test className

      table.className = table.className + ' ers-table-1-' + columnLength
      table.appendChild thead
      table.appendChild tbody

    filterFloat: (value) ->
      if /^\-?([0-9]+(\.[0-9]+)?|Infinity)$/.test(value) then Number value else NaN

    sortAgain: (collection, column, order) ->
      self = this
      collection.sort (a, b) ->
        a = a[column] or 'undefined'
        b = b[column] or 'undefined'

        a = ers.numberWithoutCommas a
        b = ers.numberWithoutCommas b

        aNumber = self.filterFloat a
        bNumber = self.filterFloat b

        isANaN = isNaN aNumber
        isBNaN = isNaN bNumber
        if isANaN isnt isBNaN
          if isANaN
            return if order then 1 else -1
          else
            return if order then -1 else 1
        else
          if isANaN
            a = JSON.stringify a if a and a.toString() is '[object Object]'
            b = JSON.stringify b if b and b.toString() is '[object Object]'

            return if order
              if a < b then -1 else (if a > b then 1 else 0)
            else
              if a < b then 1 else (if a > b then -1 else 0)

          else
            return if order then aNumber - bNumber else bNumber - aNumber

    titleClick: (e) =>
      e.preventDefault()
      target = e.target
      column = target.innerHTML
      order = target.__order
      table = @parentNode target, 4

      target.__order = not order

      # sort icon
      thTag = document.querySelectorAll('[class^=order-]')
      i = 0
      while i < thTag.length
        thTag[i].className = ''
        i++
      if order
        target.className = 'order-1'
      else
        target.className = 'order-2'

      thead = @getThead table
      columns = @thead2columns thead

      tbody = @getTbody table
      collection = @tbody2collection tbody, columns

      @sortAgain collection, column, order

      new_tbody = @collection2tbody collection, columns
      table.removeChild tbody
      table.appendChild new_tbody

    parentNode: (node, nb) ->
      i = 0
      while i < nb
        node = node.parentNode
        i++
      node

    getTable: (tableId) ->
      document.getElementById tableId

    getThead: (table) ->
      table.tHead

    getTbody: (table) ->
      table.tBodies[0]

    collection2tbody: (collection, columns) ->
      columns = columns or Object.keys collection[0]
      tbody = document.createElement 'tbody'

      for row in collection
        tr = document.createElement 'tr'
        tbody.appendChild tr

        for column in columns
          td = document.createElement 'td'
          txt = row[column]
          if txt and txt.toString() is '[object Object]'
            txt = JSON.stringify(txt).replace(/\n/g, '').replace(/,/g, ',\n')

          txt = @td txt, column, row
          td.textContent = txt
          tr.appendChild td

      tbody

    columns2thead: (columns) ->
      thead = document.createElement 'thead'
      tr = document.createElement 'tr'
      thead.appendChild tr

      for column in columns
        th = document.createElement 'th'
        tr.appendChild th


        title = document.createElement 'a'
        title.href = '#'
        title.textContent = @th column
        title.__order = true
        th.appendChild title
        title.addEventListener 'click', @titleClick

      thead

    thead2columns: (thead) ->
      th.textContent for th, i in thead.firstChild.children

    tbody2collection: (tbody, columns) ->
      for tr in tbody.children
        obj = {}
        obj[columns[i]] = td.textContent for td, i in tr.children
        obj

  ers.table = new Table

  ers.Table = Table

  ers.easyTable = (data) ->
    data = _.sortBy data, (row) -> _.keys(row).length
    data = data.reverse()
    table = document.createElement 'table'
    document.body.appendChild table
    id = _.uniqueId 'test-table'
    table.id = id
    ers.table.draw id, data
