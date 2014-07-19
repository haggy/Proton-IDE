{View} = require 'atom'

#Assign jQuery to global
window.$ = window.jQuery = require('jQuery')

module.exports =
class MetadataItemView extends View
  @content: (data) ->
    @div id: "#{data.header}-list", "data-sobject_type": "#{data.header.toLowerCase()}", class: 'sfdc-member-list', =>
      @div class: 'sfdc-top-info-cont', =>
        @h3 "#{data.header}", class: 'label label-primary sfdc-header-label'
        @span "#{data.items.length}", class: 'badge'
      @span class: 'badge sfdc-input-badge sfdc-meta-input-badge', =>
        @span "Select All"
        @input type: 'checkbox', class: "sfdc-meta-select-all-cb", checked: 'checked'
      @ul class: 'sfdc-metadata-item-list', =>
        for item in data.items
          @li id: "#{item.Id}", class: 'sfdc-metadata-list-item', =>
            @div class: 'input-group', =>
              @span class: 'input-group-addon', =>
                @input type: 'checkbox', class: 'sfdc-metadata-select-cb', 'data-sobject_id': "#{item.Id}", checked: 'checked'
              @input type: 'text', class: 'form-control', disabled: 'disabled', value: "#{item.Name}"

  toggleCheckboxes: (serializedState) ->
    checkboxes = this.find('.sfdc-metadata-select-cb')
    checkboxes.prop("checked", !checkboxes.prop("checked"))
    # Trigger change so other handlers are fired
    checkboxes.trigger('change')

  initHandlers: ->
    self = this
    # Select all cb
    self.find('.sfdc-meta-select-all-cb').on 'click', (e) ->
      console.log "Clicked!"
      self.toggleCheckboxes()

  onCheckboxChange: (cb) ->
    self = this
    self.find('.sfdc-metadata-select-cb').on 'change', (e) ->
      id = $(this).data('sobject_id')
      checked = $(this).prop('checked')
      cb(id, checked)
