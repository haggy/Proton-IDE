{View, EditorView} = require 'atom'
SfdcController = require './sfdc_core/sfdc-controller'
Config = require './helpers/config'
NewMetadataView = require './sfdc_core/new-metadata-view'
NewMetadataController = require './sfdc_core/new-metadata-controller'
RunAnonApexView = require './run-anon-apex-view'
InteractiveQueryView = require './interactive-query-view'

#Assign jQuery to global
window.$ = window.jQuery = require('jQuery')

require './ext/jquery-center.js'

module.exports =
class SfdcView extends View
  @defaultProjPath: Config.read('project_path')

  @content: ->
    @div class: 'overlay sfdc-overlay', =>
      @ul id: 'sfdc-main-tabs', class: 'nav nav-tabs', role: 'tablist', =>
        @li class: 'active', =>
          @a "Connect", role: 'tab', 'data-toggle': 'tab', href: '#sfdc-connect-pane'
        @li class: '', =>
          @a "Select Metadata", role: 'tab', 'data-toggle': 'tab', href: '#sfdc-metadata-tab'

      @div class: 'tab-content', tabIndex: -1, =>
        @div class: 'tab-pane active', id: 'sfdc-connect-pane', =>
          @div class: 'container', =>
            @div class: 'row sfdc-row-marg-5', =>
              # @div class: 'col-sm-6', =>
              #   @label "Username:", for: 'sfdc-username', class: 'sfdc-label',
              # @div class: 'col-sm-6', =>
              #   @input type: 'text', class: 'form-control sfdc-input sfdc-input-text', name: 'sfdc-username', id: 'sfdc-username'
                @div class: 'col-sm-12', =>
                   @div class: 'editor-container', =>
                       @subview 'usernameEditor', new EditorView(mini: true, placeholderText: 'Username')
            @div class: 'row sfdc-row-marg-5', =>
              # @div class: 'col-sm-6', =>
              #   @label "Password:", for: 'sfdc-password', class: 'sfdc-label'
              # @div class: 'col-sm-6', =>
              #   @input type: 'password', class: 'form-control sfdc-input sfdc-input-text', name: 'sfdc-password', id: 'sfdc-password', 'tab-index': 2
              @div class: 'col-sm-12', =>
                @div class: 'editor-container', =>
                  @subview 'passwordEditor', new EditorView(mini: true, placeholderText: 'Password')
            @div class: 'row sfdc-row-marg-5', =>
              # @div class: 'col-sm-2', =>
              #   @label "Environment:", for: 'sfdc-environment', class: 'sfdc-label', id: 'sfdc-env-label'
              @div class: 'col-sm-4', =>
                @div id: 'sfdc-env-select', class: 'btn-group', =>
                  @button type: 'button', class: 'btn btn-default dropdown-toggle', 'data-toggle': 'dropdown', =>
                    @span "Select Environment"
                    @span class: 'caret sfdc-margin-left-5'
                  @ul class: 'dropdown-menu', role: 'menu', =>
                    @li =>
                      @a "Production", href: '#', 'data-environment': 'production'
                    @li =>
                      @a "Sandbox", href: '#', 'data-environment': 'sandbox'
                    @li =>
                      @a "Developer", href: '#', 'data-environment': 'developer'

            @div id: 'sfdc-login-btn-cont', class: 'row sfdc-row-marg-5', =>
              @div class: 'col-sm-4 col-md-offset-4', =>
                @input outlet: 'loginButton', type: 'button', value: 'Login', class: 'btn sfdc-btn-full', id: 'login-btn'
            @div class: 'row sfdc-row-marg-5', =>
              @div class: 'col-sm-12', =>
                @div id: 'sfdc-connect-msg', =>
                  @span "Login successful!"

        @div class: 'tab-pane', id: 'sfdc-metadata-tab', =>
          @div id: 'sfdc-metadata-select'

          @div class: 'container sfdc-project-props', =>
            @div class: 'row', =>
              @div class: 'col-sm-4', =>
                @div class: 'input-group', =>
                  @span "/", class: 'input-group-addon'
                  @input id: 'sfdc-project-path', type: 'text', class: 'form-control', value: "#{@defaultProjPath}"
            @div class: 'row', =>
              @div class: 'col-sm-4', =>
                @div class: 'input-group', =>
                  @span "+", class: 'input-group-addon'
                  @input id: 'sfdc-project-name', type: 'text', class: 'form-control', placeholder: 'Project Name...'
          @div id: 'sfdc-proj-btn-group', class: 'btn-group', =>
            @button "Create Project", id: 'sfdc-create-proj-btn', type: 'button', class:'btn'
            @button "Cancel", id: 'sfdc-cancel-proj-btn', type: 'button', class:'btn btn-warning'

  initialize: (serializeState) ->
    atom.workspaceView.command "sfdc:toggle", => @toggle()
    atom.workspaceView.command "sfdc:refreshProject", => @toggle(true)
    atom.workspaceView.command "sfdc:saveCurrentFile", => @saveCurrentFile()
    atom.workspaceView.command "sfdc:refreshCurrentFile", => @refreshCurrentFile()
    atom.workspaceView.command "sfdc:deleteCurrentFile", => @deleteCurrentFile()
    atom.workspaceView.command "sfdc:createClass", => @createClass()
    atom.workspaceView.command "sfdc:createPage", => @createPage()
    atom.workspaceView.command "sfdc:createTrigger", => @createTrigger()
    atom.workspaceView.command "sfdc:createComponent", => @createComponent()
    atom.workspaceView.command "sfdc:executeApex", => @executeApex()
    atom.workspaceView.command "sfdc:interactiveQuery", => @interactiveQuery()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    this.find('#sfdc-metadata-select').html('Loading metadata...')
    @detach()
    this.remove()

  showMetaLoader: ->
    this.find('#sfdc-metadata-select').html('<span id="metadata-loader">Loading metadata...')

  hideMetaLoader: ->
    this.find('#metadata-loader').remove()

  toggle: (isRefresh = false) ->
    if @hasParent()
      @destroy()
    else
      this.data('is_refresh', isRefresh)
      atom.workspaceView.append(this)
      @cont = new SfdcController(this)

  getUtilityController: ->
    if not @utilController?
      @utilController = new SfdcController()
    return @utilController

  saveCurrentFile: ->
    this.getUtilityController().saveFile()

  refreshCurrentFile: ->
    this.getUtilityController().refreshCurrentFile()

  deleteCurrentFile: ->
    this.getUtilityController().deleteCurrentFile()

  createClass: ->
    params =
      type: 'class'
      description: 'Enter a name for the Apex Class'
      fields:
        Name: 'Class Name'
    metaView = new NewMetadataView(params)
    atom.workspaceView.append(metaView)
    new NewMetadataController(metaView)

  createTrigger: ->
    params =
      type: 'trigger'
      description: 'Enter a name and type for the Apex Trigger'
      fields:
        Name: 'Trigger Name'
        TableEnumOrId: 'Object Type'
    metaView = new NewMetadataView(params)
    atom.workspaceView.append(metaView)
    new NewMetadataController(metaView)

  createPage: ->
    params =
      type: 'page'
      description: 'Enter a name for the new Visualforce Page'
      fields:
        Name: 'Page API Name'
        MasterLabel: 'Label'

    metaView = new NewMetadataView(params)
    atom.workspaceView.append(metaView)
    new NewMetadataController(metaView)

  createComponent: ->
    params =
      type: 'component'
      description: 'Enter a name for the new Component'
      fields:
        Name: 'API Name'
        MasterLabel: 'Label'

    metaView = new NewMetadataView(params)
    atom.workspaceView.append(metaView)
    new NewMetadataController(metaView)

  center: ->
    $(this).center()

  executeApex: ->
    new RunAnonApexView({}).toggle()

  interactiveQuery: ->
    new InteractiveQueryView().toggle()
