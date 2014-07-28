BaseController = require './base-controller'
ApexClassService = require './apex-class-service'
ApexPageService = require './apex-page-service'
ApexComponentService = require './apex-component-service'
ApexTriggerService = require './apex-trigger-service'

module.exports =
class NewMetadataController extends BaseController

  constructor: (view) ->
    super(view)

    if view
      this.init()

  init: ->
    self = this

    @view.find('#sfdc-create-metadata-btn').click (e) ->
      self.createRecord()

    @view.on 'keyup', 'input', (e) ->
      if e.keyCode is 27
        self.view.destroy()
      else if e.keyCode is 13
        self.createRecord()

  createRecord: ->
    self = this

    loader = self.getAsyncLoader('Creating some new files...')
    loader.show()

    params = {}
    params.type = self.view.data('meta_type')
    self.view.find('.sfdc-input').each (idx, elem) ->
      params[$(elem).attr('name')] = $(elem).val()

    accessToken = self.getAccessToken()

    onResult = (err, path) ->
      loader.remove()
      if err
        alert "Error creating metadata:\n\n#{err}"
        return
      self.view.destroy()
      atom.workspace.open(path)

    service = null
    switch(params.type)
      when 'class'
        service = new ApexClassService(accessToken)
      when 'trigger'
        service = new ApexTriggerService(accessToken)
      when 'page'
        service = new ApexPageService(accessToken)
      when 'component'
        service = new ApexComponentService(accessToken)


    if not service
      alert "Invalid metadata type"
      return

    service.create params, onResult
