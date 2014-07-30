{EditorView} = require 'atom'
BaseController = require './base-controller'
QueryService = require './query-service'

window.$ = window.jQuery = require('jQuery')
require '../ext/jquery.dynatable.js'

module.exports =
class InteractiveQueryController extends BaseController

  constructor: (view) ->
    super(view)

    @initHandlers()

  initHandlers: ->
    @view.execQueryButton.click (e) => @doQuery()
    @view.exitQueryButton.click (e) => @destroy()
    @view.saveRowsButton.click (e) => @saveRows()
    @view.selectEditor.keyup (e) => @doQueryOnEnter(e)
    @view.fromEditor.keyup (e) => @doQueryOnEnter(e)
    @view.whereEditor.keyup (e) => @doQueryOnEnter(e)

  destroy: ->
    this.view.destroy()

  handleTableCellClick: (e) ->
    e.preventDefault()
    $td = $(e.target)
    if $td.hasClass 'sfdc-table-cell-active' then return

    $td.addClass('sfdc-table-cell-active')
    origVal = $td.html()

    if not $td.data('orig_value')
      $td.data('orig_value', origVal)

    input = $('<input type="text"/>').addClass('form-control')
    input.val(origVal)
    input.keyup (e) ->

      if e.keyCode is 13
        if input.val() isnt origVal
          $td.addClass('sfdc-table-cell-changed')
          $td.parent().addClass('sfdc-table-row-changed')

        $td.html(input.val())
        $td.removeClass('sfdc-table-cell-active')

    $td.html(input)

  saveRows: ->
    @view.removeError()
    changedRowsSel = '#sfdc-interactive-table tr.sfdc-table-row-changed'
    changedRows = this.view.find(changedRowsSel).toArray()
    if changedRows.length is 0 then return

    qs = new QueryService @getAccessToken()
    objType = this.view.fromEditor.getText().trim()
    # Header rows which contain the column ID/Name
    headerCells = this.view.find('.dynatable-head')

    curr = null

    getObjectFromRow = (row) =>
      cells = row.find('td')
      @logInfo 'matched cells =', cells
      data = {}
      cells.each (idx, elem) ->
        fieldName = $(headerCells[idx]).data('dynatable-column')
        # Don't include related fields
        if fieldName.indexOf('.') > -1
          return true

        data[fieldName] = $(this).html()

      @logInfo "CHANGED: ", data
      return data

    updateRecord = (data, res) =>
      @logInfo "Row updated: ", data

      if @isErrorResult data
        @logError @getErrorFromResult(data)
        @view.addError @getErrorFromResult(data)
        return

      # Remove style from last cell
      curr.removeClass('sfdc-table-row-changed')
      .find('td')
      .removeClass('sfdc-table-cell-changed')

      if changedRows.length is 0
        return

      curr = $(changedRows.pop())
      data = getObjectFromRow(curr)
      qs.save objType, data.id, data, updateRecord

    curr = $(changedRows.pop())
    data = getObjectFromRow(curr)
    qs.save objType, data.id, data, updateRecord

  doQueryOnEnter: (e) ->
    if e.keyCode is 13
      e.preventDefault()
      @doQuery()
    else if e.keyCode is 27 #Escape
      e.preventDefault()
      @destroy()

  doQuery: ->
    @view.removeError()
    select = this.view.selectEditor.getText()
    from = this.view.fromEditor.getText()
    where = this.view.whereEditor.getText()

    if not select or not from then return

    # Make sure ID is included
    selectParts = select.toLowerCase().split(',')
    console.log selectParts
    trimmedSelectParts = []
    trimmedSelectParts.push part.toLowerCase() for part in selectParts
    console.log trimmedSelectParts
    if trimmedSelectParts.indexOf('id') < 0
      select += ", Id"

    qs = new QueryService @getAccessToken()
    qs.query select, from, where, (err, res) =>
      if err?
        @logError err
        @view.addError err
        return

      @logInfo "Received #{res.length} records: ", res

      tableConfig =
        table:
          defaultColumnIdStyle: 'lowercase'
        dataset:
          records: res

      @addNewTable()
      table = $('#sfdc-interactive-table')
      @addHeaders select, table
      table.dynatable tableConfig

  addHeaders: (select) ->
    parts = select.split ','
    header = $('<tr></tr>')
    for part in parts
      trimmed = part.trim()
      header.append "<th>#{trimmed}</th>"

    this.view.find('#sfdc-interactive-table thead').append header

  addNewTable: ->
    cont = @view.find('#sfdc-interactive-table-cont')
    cont.empty()

    table = $('<table/>')
    .attr('id', 'sfdc-interactive-table')
    .addClass('table table-bordered')
    table.on 'dblclick', 'tbody td', (e) => @handleTableCellClick(e)

    header = $('<thead/>').addClass('sfdc-interactive-table-header')
    table.append(header)
    cont.append(table)
