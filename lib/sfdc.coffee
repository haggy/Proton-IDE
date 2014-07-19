SfdcView = require './sfdc-view'

#Assign jQuery to global
window.$ = window.jQuery = require('jQuery')

module.exports =
  sfdcView: null

  activate: (state) ->
    @sfdcView = new SfdcView(state.sfdcViewState)
    atom.workspaceView.command "sfdc:convert", => @convert()

  deactivate: ->
    @sfdcView.destroy()

  serialize: ->
    sfdcViewState: @sfdcView.serialize()

  convert: ->
    # This assumes the active pane item is an editor
    editor = atom.workspace.activePaneItem
    editor.insertText('Hello, World!')

  saveCurrentFile: ->
    console.log 'Saving to server...'
