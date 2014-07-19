{View} = require 'atom'
SfdcController = require './sfdc_core/sfdc-controller'
Config = require './helpers/config'
#Assign jQuery to global
window.$ = window.jQuery = require('jQuery')

module.exports =
class SfdcView extends View
  @defaultProjPath: Config.read('project_path')

  @content: ->
    @div class: 'overlay sfdc-connect', =>
      @ul id: 'sfdc-main-tabs', class: 'nav nav-tabs', role: 'tablist', =>
        @li class: 'active', =>
          @a "Connect", role: 'tab', 'data-toggle': 'tab', href: '#sfdc-connect-pane'
        @li class: '', =>
          @a "Select Metadata", role: 'tab', 'data-toggle': 'tab', href: '#sfdc-metadata-tab'

      @div class: 'tab-content', =>
        @div class: 'tab-pane active', id: 'sfdc-connect-pane', =>
          @div class: 'container', =>
            @div class: 'row sfdc-row-marg-5', =>
              @div class: 'col-sm-6', =>
                @label "Username:", for: 'sfdc-username', class: 'sfdc-label'
              @div class: 'col-sm-6', =>
                @input type: 'text', class: 'sfdc-input sfdc-input-text', name: 'sfdc-username', id: 'sfdc-username'
            @div class: 'row sfdc-row-marg-5', =>
              @div class: 'col-sm-6', =>
                @label "Password:", for: 'sfdc-password', class: 'sfdc-label'
              @div class: 'col-sm-6', =>
                @input type: 'password', class: 'sfdc-input sfdc-input-text', name: 'sfdc-password', id: 'sfdc-password'
            @div class: 'row sfdc-row-marg-5', =>
              @div class: 'col-sm-6', =>
                @label "Environment:", for: 'sfdc-environment', class: 'sfdc-label'
              @div class: 'col-sm-6', =>
                @div id: 'sfdc-env-select', class: 'btn-group', =>
                  @button "Select", type: 'button', class: 'btn btn-default dropdown-toggle', 'data-toggle': 'dropdown', =>
                    @span class: 'caret'
                  @ul class: 'dropdown-menu', role: 'menu', =>
                    @li =>
                      @a "Production", href: '#', 'data-environment': 'production'
                    @li =>
                      @a "Sandbox", href: '#', 'data-environment': 'sandbox'
                    @li =>
                      @a "Developer", href: '#', 'data-environment': 'developer'

            @div class: 'row sfdc-row-marg-5', =>
              @div class: 'col-sm-12', =>
                @input type: 'button', value: 'Login', class: 'btn btn-full', id: 'login-btn'
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
    atom.workspaceView.command "sfdc:saveCurrentFile", => @saveCurrentFile()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    this.find('#sfdc-metadata-select').html('Loading metadata...')
    @detach()

  showMetaLoader: ->
    this.find('#sfdc-metadata-select').html('<span id="metadata-loader">Loading metadata...')

  hideMetaLoader: ->
    this.find('#metadata-loader').remove()

  toggle: ->
    console.log "SfdcView was toggled!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
      @cont = new SfdcController(this)

  saveCurrentFile: ->
    console.log 'Saving to server....'
    cont = new SfdcController()
    cont.saveFile()
