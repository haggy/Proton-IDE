BaseController = require './base-controller'
Config = require '../helpers/config'
RunAnonApexService = require './run-anon-apex-service'

module.exports =
class RunAnonApexController extends BaseController

  constructor: (view) ->
    super(view)
    this.initHandlers()

  initHandlers: ->
    this.view.apexEditor.on 'keyup', (e) => @handleEditorKeypress(e)
    this.view.execApexButton.click (e) => @executeApex(e)
    this.view.exitAnonApexButton.click (e) => @closeWindow(e)

    # Enable tabs
    $('#sfdc-run-anon-apex-tabs a').click (e) ->
      e.preventDefault()
      $(this).tab('show')

  handleEditorKeypress: (e) ->
    if e.keyCode is 27
      @closeWindow(e)

  closeWindow: (e) ->
    this.view.destroy()

  executeApex: ->
    @logInfo "Executing Apex..."
    apex = this.view.apexEditor.val()
    if not apex
      return

    this.view.removeError()
    loader = this.getAsyncLoader('Running your codez...')
    loader.show()
    new RunAnonApexService(this.getAccessToken()).execute apex, (err, res) =>
      loader.remove()
      @logInfo "Anon apex result: ", res
      if err?
        @logError err
        this.view.addError(err, res.line)
        return
      debugInfo = if res.debugInfo then res.debugInfo else "Your codez were run successfully!"
      this.view.find('#sfdc-debug-log').html(debugInfo)
      this.view.switchTab('sfdc-anon-apex-results-pane')
