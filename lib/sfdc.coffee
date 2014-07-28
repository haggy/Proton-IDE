SfdcView = require './sfdc-view'
Config = require './helpers/config'
#Assign jQuery to global
window.$ = window.jQuery = require('jQuery')

module.exports =
  sfdcView: null

  configDefaults:
    proton:
      project_path: ''

  activate: (state) ->
    # Set default config
    if not Config.read('project_path')
      Config.write('project_path', '')

    if not Config.read('api_version')
      Config.write('api_version', '30.0')

    if not Config.read('debug')
      Config.write('debug', '0')

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
