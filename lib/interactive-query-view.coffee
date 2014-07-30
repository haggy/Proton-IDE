{View, EditorView} = require 'atom'
InteractiveQueryController = require './sfdc_core/interactive-query-controller'

module.exports =
class InteractiveQueryView extends View

  @content: ->
    @div id: 'sfdc-interactive-query', class: 'overlay sfdc-overlay', =>
      @div class: 'sfdc-error-message'
      @div class: 'container', =>
        @div class: 'row sfdc-row-marg-5', =>
          @div class: 'col-sm-6', =>
            @div class: 'editor-container', =>
              @subview 'selectEditor', new EditorView(mini: true, placeholderText: 'Type select fields (with commas)')
        @div class: 'row sfdc-row-marg-5', =>
          @div class: 'col-sm-6', =>
            @div class: 'editor-container', =>
              @subview 'fromEditor', new EditorView(mini: true, placeholderText: 'Put object type here (Account, Contact etc)')
        @div class: 'row sfdc-row-marg-5', =>
          @div class: 'col-sm-6', =>
            @div class: 'editor-container', =>
              @subview 'whereEditor', new EditorView(mini: true, placeholderText: 'Put where statement here (Name = \'Blah\')')
        @div class: 'row sfdc-row-marg-5', =>
          @div class: 'col-sm-12', =>
            @div id: 'sfdc-interactive-table-cont', class: 'native-key-bindings', tabindex: -1, =>
        @div class: 'row sfdc-row-marg-5', =>
          @div class: 'col-sm-4', =>
            @div id: 'sfdc-anon-apex-group', class: 'btn-group', =>
              @button "Execute Query", outlet: 'execQueryButton', class: 'btn btn-info'
              @button "Save rows", outlet: 'saveRowsButton', class: 'btn btn-info'
              @button "Close", outlet: 'exitQueryButton', class: 'btn btn-warning'

  initialize: (serializedConfig) ->


  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
      @cont = new InteractiveQueryController(this)

  addError: (msg) ->
    console.log "Adding #{msg}"
    this.find('.sfdc-error-message').html(msg)

  removeError: ->
    this.find('.sfdc-error-message').html('')
