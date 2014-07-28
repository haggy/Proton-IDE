{View, Editor, EditorView} = require 'atom'
TextBuffer = require 'text-buffer'
RunAnonApexController = require './sfdc_core/run-anon-apex-controller'

#Assign jQuery to global
window.$ = window.jQuery = require('jQuery')

module.exports =
class RunAnonApexView extends View

  @content: (params) ->
    @div id: 'run-anon-apex-cont', tabIndex: -1, class: 'native-key-bindings overlay sfdc-overlay',  =>
      @ul id: 'sfdc-run-anon-apex-tabs', class: 'nav nav-tabs', role: 'tablist', =>
        @li class: 'active', =>
          @a "Apex Code", role: 'tab', 'data-toggle': 'tab', href: '#sfdc-anon-apex-code-pane'
        @li class: '', =>
          @a "Results", role: 'tab', 'data-toggle': 'tab', href: '#sfdc-anon-apex-results-pane'
      @div class: 'tab-content', =>
        @div class: 'tab-pane active', id: 'sfdc-anon-apex-code-pane', =>
          @div class: 'container', =>
            @div class: 'row sfdc-row-marg-5', =>
              @div class: 'col-sm-12', =>
                # UNABLE to user EditorView as I cannot figure out
                # how to create a textarea component
                # @div class: 'editor-container', =>
                #   @subview 'apexEditor',
                #     new EditorView(new Editor(
                #       buffer: new TextBuffer
                #       softWrap: false
                #       tabLength: 2
                #       softTabs: true
                #     ))
                @textarea outlet: 'apexEditor', class: 'form-control sfdc-full'
                @div id: 'sfdc-exec-anon-errors', =>
                  @p ""
            @div class: 'row sfdc-row-marg-5', =>
              @div class: 'col-sm-4', =>
                @div id: 'sfdc-anon-apex-group', class: 'btn-group', =>
                  @button "Execute Apex", outlet: 'execApexButton', class: 'btn btn-info'
                  @button "Close", outlet: 'exitAnonApexButton', class: 'btn btn-warning'
        @div class: 'tab-pane', id: 'sfdc-anon-apex-results-pane', =>
          @div class: 'container', =>
            @p id: 'sfdc-debug-log'

  initialize: (params) ->

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
      @cont = new RunAnonApexController(this)

  addError: (text, line) ->
    # Remove any GT/LT signs
    text = text.replace(/</g, '').replace(/>/g, '')
    this.find('#sfdc-exec-anon-errors > p').html("#{text}<br/>Line: #{line}")

  removeError: ->
    this.find('#sfdc-exec-anon-errors > p').html('')

  switchTab: (tabId) ->
    query = "a[href=\"##{tabId}\"]"
    $(query).tab('show')
