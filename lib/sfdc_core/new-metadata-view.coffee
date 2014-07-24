{View} = require 'atom'

window.$ = window.jQuery = require('jQuery')

module.exports =
class NewMetadataView extends View

  @content: (params) ->
    @div id: 'create-new-metadata', 'data-meta_type': "#{params.type}", class:'overlay from-top', =>
      @h3 "#{params.description}"
      @div class: 'container', =>
        for name, label of params.fields
          @div class: 'row sfdc-row-marg-5', =>
            @div class: 'col-sm-2 col-md-offset-4', =>
              @label "#{label}:", class: 'sfdc-label'
            @div class: 'col-sm-3', =>
              @input type: 'text', class: 'form-control sfdc-input sfdc-input-text', name: "#{name}", id: "sdc-new-meta-field-#{name}"
        @div class: 'row sfdc-row-marg-5', =>
          @div class: 'col-sm-5 col-md-offset-4', =>
            @button "Create", type: 'button', class: 'btn btn-info', id: 'sfdc-create-metadata-btn'

  initialize: (serializeState) ->

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    this.find('.sfdc-input').val('')
    @detach()
