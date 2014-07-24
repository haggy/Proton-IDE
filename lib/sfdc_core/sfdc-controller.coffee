fs = require 'fs'
fsPlus = require 'fs-plus'
async = require 'async'
BaseController = require './base-controller'
Config = require '../helpers/config'
AtomHelper = require '../helpers/atom-helper'
SfdcAuthService = require './sfdc-auth-service'
MetadataFileHelper = require '../helpers/metadata-file-helper'
ApexClassService = require './apex-class-service'
ApexPageService = require './apex-page-service'
ApexComponentService = require './apex-component-service'
ApexTriggerService = require './apex-trigger-service'
MetadataContainerService = require './metadata-container-service'
MetadataItemView = require './metadata-item-view'

#Assign jQuery to global
# For some reason, using Atom builtin jQuery doesn't work
# with dropdown menus
window.$ = window.jQuery = require 'jQuery'

require '../ext/bootstrap/tabs.js'
require '../ext/bootstrap/dropdowns.js'

module.exports =
class SfdcController extends BaseController

  constructor: (view) ->
    super(view)
    if @view
      this.init()

    # List of mdetdata components that are "dirty"
    # Dirty in this case means that the last modified user on
    # a piece of metadata is not the current user.
    @dirtyMetadataIds = []

  init: ->
    self = this

    self.view.loginButton.on 'click', => @doLogin()

    self.view.on 'keyup', 'input', (e) ->
      if e.keyCode is 27
        self.view.destroy()
      else if e.keyCode is 13
        self.doLogin()

    # Enable tabs
    $('#sfdc-main-tabs a').click (e) ->
      e.preventDefault()
      $(this).tab('show')

      if $(this).attr('href') is '#sfdc-metadata-tab'
        self.view.showMetaLoader()
        self.selectMetadata()

    # Environment select event handler
    $('#sfdc-env-select ul li a').on 'click', (e) ->
      self.setEnvironment $(this).data('environment')
      $(this).parents(".btn-group").children('.btn:first-child').text($(this).text())

    # Create and Cancel project buttons
    $('#sfdc-cancel-proj-btn').on 'click', (e) ->
      self.view.destroy()

    $('#sfdc-create-proj-btn').on 'click', (e) ->
      self.createProject()

    # add username from config if it has been used before
    self.view.usernameEditor.setText(Config.read('uname'))

    # Handle sensitive text replacement on password field
    self.view.passwordEditor.getEditor().on 'contents-modified', => @handleSensitiveText()

  setDirtyMetadata: (id) ->
    @dirtyMetadataIds.push(id)

  isDirty: (id) ->
    return @dirtyMetadataIds.indexOf(id) > 0

  clearDirtyMetadata: (id) ->
    var idx = @dirtyMetadataIds.indexOf(id)
    if idx > 0
      @dirtyMetadataIds.splice(idx, 1)

  setEnvironment: (env) ->
    @environment = env

  getEnvironment: ->
    if not @environment
      @environment = 'production'
    return @environment

  handleSensitiveText: ->
    text = this.view.passwordEditor.getText()
    spanLine = this.view.passwordEditor.find('span.text.plain')
    spanLine.html('')
    for char in text
      spanLine.append('*')

  doLogin: ->
    self = this

    uname = self.view.usernameEditor.getText()
    pass = self.view.passwordEditor.getText()
    env = self.getEnvironment()
    Config.write('uname', uname)
    SfdcAuthService.login env, uname, pass, (success, tokenOrError, domain, userId) ->
      msgs = self.view.find('#sfdc-connect-msg')

      if not success
        msgs.find('span').css({color: '#F00'}).html(tokenOrError)
        msgs.fadeIn()
        return

      self.token = tokenOrError
      Config.write('token', self.token)
      Config.write('domain', domain)
      Config.write('user_id', userId)
      msgs.find('span').css({color: '#0F0'}).html("Login successful!")
      msgs.fadeIn()


  wipeData: ->
    this.classes = []
    this.pages = []
    this.trigs = []
    this.comps = []
    this.classArrayIndexMap = {}
    this.pageArrayIndexMap = {}
    this.trigArrayIndexMap = {}
    this.compArrayIndexMap = {}

  selectMetadata: ->
    self = this
    accessToken = @token

    loadClasses = (cb) ->
      classServ = new ApexClassService(accessToken)
      classServ.retrieveAll (classes) ->
        self.view.hideMetaLoader()
        if not classes or classes.length is 0
          cb(null, 'classes')
          return
        self.classes = classes
        console.log self.classes
        # Map of record ID to index
        self.classArrayIndexMap = {}
        self.classes.forEach (item, idx) ->
          item.selected = true
          self.classArrayIndexMap[item.Id] = idx

        metaView = new MetadataItemView(header:'Classes', items: classes)
        self.view.find('#sfdc-metadata-select').append(metaView)
        metaView.initHandlers()
        metaView.onCheckboxChange (id, checked) ->
          idx = self.classArrayIndexMap[id]
          self.classes[idx].selected = checked
        cb(null, 'classes')

    loadPages = (cb) ->
      pagesServ = new ApexPageService(accessToken)
      pagesServ.retrieveAll (pages) ->
        self.view.hideMetaLoader()
        if not pages or pages.length is 0
          cb(null, 'pages')
          return
        self.pages = pages
        # Map of record ID to index
        self.pageArrayIndexMap = {}
        self.pages.forEach (item, idx) ->
          self.pageArrayIndexMap[item.Id] = idx
          item.selected = true

        metaView = new MetadataItemView(header:'Pages', items: pages)
        self.view.find('#sfdc-metadata-select').append(metaView)
        metaView.initHandlers()
        metaView.onCheckboxChange (id, checked) ->
          idx = self.pageArrayIndexMap[id]
          self.pages[idx].selected = checked
        cb(null, 'pages')

    loadComponents = (cb) ->
      componentServ = new ApexComponentService(accessToken)
      componentServ.retrieveAll (comps) ->
        self.view.hideMetaLoader()
        if not comps or comps.length is 0
          cb(null, 'comps')
          return
        self.comps = comps
        # Map of record ID to index
        self.compArrayIndexMap = {}
        self.comps.forEach (item, idx) ->
          item.selected = true
          self.compArrayIndexMap[item.Id] = idx

        metaView = new MetadataItemView(header:'Components', items: comps)
        self.view.find('#sfdc-metadata-select').append(metaView)
        metaView.initHandlers()
        metaView.onCheckboxChange (id, checked) ->
          idx = self.compArrayIndexMap[id]
          self.comps[idx].selected = checked
        cb(null, 'comps')

    loadTriggers = (cb) ->
      triggerServ = new ApexTriggerService(accessToken)
      triggerServ.retrieveAll (trigs) ->
        self.view.hideMetaLoader()
        if not trigs or trigs.length is 0
          cb(null, 'trigs')
          return
        self.trigs = trigs
        # Map of record ID to index
        self.trigArrayIndexMap = {}
        self.trigs.forEach (item, idx) ->
          self.trigArrayIndexMap[item.Id] = idx
          item.selected = true

        metaView = new MetadataItemView(header:'Triggers', items: trigs)
        self.view.find('#sfdc-metadata-select').append(metaView)
        metaView.initHandlers()
        metaView.onCheckboxChange (id, checked) ->
          idx = self.trigArrayIndexMap[id]
          self.trigs[idx].selected = checked
        cb(null, 'trigs')

    loader = self.getAsyncLoader('Loading all the metadata...')
    loader.show()

    async.series [loadClasses, loadTriggers, loadPages, loadComponents], (res) ->
      loader.remove()

  getSelected: (objList) ->
    selected = []
    objList.forEach (item, idx) ->
      if item.selected
        selected.push item
    return selected

  createProject: ->
    self = this
    fullPath = this.createProjectDirectory()
    if not fullPath
      return

    loader = self.getAsyncLoader('Creating a shiny, new project...')
    loader.show()

    async.series
      classes: (cb) ->
        self.createProjectClassFiles fullPath, (res) ->
          console.log res
          cb(null, 'classes')
      pages: (cb) ->
        self.createProjectPageFiles fullPath, (res) ->
          console.log res
          cb(null, 'pages')
      triggers: (cb) ->
        self.createProjectTriggerFiles fullPath, (res) ->
          console.log res
          cb(null, 'triggers')
      components: (cb) ->
        self.createProjectComponentFiles fullPath, (res) ->
          console.log res
          cb(null, 'components')
      , (results) ->
        atom.open pathsToOpen: [fullPath]
        self.wipeData()
        self.view.destroy()
        loader.remove()

  createProjectDirectory: ->
    projName = $('#sfdc-project-name').val()
    path = $('#sfdc-project-path').val()

    if not projName or not path
      alert 'Please enter a project name and path'
      return
    if projName.indexOf(' ') > -1
      alert 'The project name cannot contain spaces'
      return

    fullPath = fsPlus.makeTreeSync("#{path}/#{projName}")
    if not fullPath
      alert "Project already exists!"

    return fullPath


  createProjectClassFiles: (fullPath, cb) ->
    self = this
    currRecord = null

    if not self.classes or self.classes.length is 0
      cb('NO CLASSES')
      return

    selected = self.getSelected self.classes
    if selected.length is 0
      cb('NO CLASSES SELECTED')
      return

    createFileResult = (createRes) ->
      console.log createRes

      if currRecord
        metaFileName = currRecord.Name + '.cls.meta.json'
        metadata =
          id: currRecord.Id
          version: currRecord.ApiVersion
          type: 'class'
        metaFileContent = JSON.stringify metadata
        currRecord = null
        fsPlus.writeFile "#{fullPath}/classes/#{metaFileName}", metaFileContent, null, createFileResult
        return

      if selected.length > 0
        currRecord = selected.shift()
        nextFileName = currRecord.Name + '.cls'
        nextContent = currRecord.Body
        fsPlus.writeFile "#{fullPath}/classes/#{nextFileName}", nextContent, null, createFileResult
      else
        cb('CLASS FILES WRITTEN!')

    currRecord = selected.shift()
    fileName = currRecord.Name + '.cls'
    content = currRecord.Body
    fsPlus.writeFile "#{fullPath}/classes/#{fileName}", content, null, createFileResult

  createProjectTriggerFiles: (fullPath, cb) ->
    self = this
    currRecord = null

    if not self.trigs or self.trigs.length is 0
      cb('NO TRIGGERS')
      return

    selected = self.getSelected self.trigs
    if selected.length is 0
      cb('NO TRIGGERS SELECTED')
      return

    createFileResult = (createRes) ->
      console.log createRes

      if currRecord
        metaFileName = currRecord.Name + '.trigger.meta.json'
        metadata =
          id: currRecord.Id
          version: currRecord.ApiVersion
          status: currRecord.Status
          type: 'trigger'
        metaFileContent = JSON.stringify metadata
        currRecord = null
        fsPlus.writeFile "#{fullPath}/triggers/#{metaFileName}", metaFileContent, null, createFileResult
        return

      if selected.length > 0
        currRecord = selected.shift()
        nextFileName = currRecord.Name + '.trigger'
        nextContent = currRecord.Body
        fsPlus.writeFile "#{fullPath}/triggers/#{nextFileName}", nextContent, null, createFileResult
      else
        cb('TRIGGER FILES WRITTEN!')

    currRecord = selected.shift()
    fileName = currRecord.Name + '.trigger'
    content = currRecord.Body
    fsPlus.writeFile "#{fullPath}/triggers/#{fileName}", content, null, createFileResult


  createProjectPageFiles: (fullPath, cb) ->
    self = this
    currRecord = null

    if not self.pages or self.pages.length is 0
      cb('NO PAGES')
      return

    selected = self.getSelected self.pages
    if selected.length is 0
      cb('NO PAGES SELECTED')
      return

    createFileResult = (createRes) ->
      console.log createRes

      if currRecord
        metaFileName = currRecord.Name + '.page.meta.json'
        metadata =
          id: currRecord.Id
          version: currRecord.ApiVersion
          type: 'page'
        metaFileContent = JSON.stringify metadata
        currRecord = null
        fsPlus.writeFile "#{fullPath}/pages/#{metaFileName}", metaFileContent, null, createFileResult
        return

      if selected.length > 0
        currRecord = selected.shift()
        nextFileName = currRecord.Name + '.page'
        nextContent = currRecord.Markup
        fsPlus.writeFile "#{fullPath}/pages/#{nextFileName}", nextContent, null, createFileResult
      else
        cb('PAGE FILES WRITTEN!')

    currRecord = selected.shift()
    fileName = currRecord.Name + '.page'
    content = currRecord.Markup
    fsPlus.writeFile "#{fullPath}/pages/#{fileName}", content, null, createFileResult

  createProjectComponentFiles: (fullPath, cb) ->
    self = this
    currRecord = null

    if not self.comps or self.comps.length is 0
      cb('NO COMPONENTS')
      return

    selected = self.getSelected self.comps
    if selected.length is 0
      cb('NO COMPONENTS SELECTED')
      return

    createFileResult = (createRes) ->
      console.log createRes

      if currRecord
        metaFileName = currRecord.Name + '.component.meta.json'
        metadata =
          id: currRecord.Id
          version: currRecord.ApiVersion
          type: 'component'
        metaFileContent = JSON.stringify metadata
        currRecord = null
        fsPlus.writeFile "#{fullPath}/components/#{metaFileName}", metaFileContent, null, createFileResult
        return

      if selected.length > 0
        currRecord = selected.shift()
        nextFileName = currRecord.Name + '.component'
        nextContent = currRecord.Markup
        fsPlus.writeFile "#{fullPath}/components/#{nextFileName}", nextContent, null, createFileResult
      else
        cb('COMPONENT FILES WRITTEN!')

    currRecord = selected.shift()
    fileName = currRecord.Name + '.component'
    content = currRecord.Markup
    fsPlus.writeFile "#{fullPath}/components/#{fileName}", content, null, createFileResult


  saveFile: ->
    self = this
    accessToken = self.getAccessToken()
    if not accessToken
      alert 'You must login to perform this operation'
      return

    loader = self.getAsyncLoader('Deploying your codez to SFDC...')
    loader.show()

    fileContents = AtomHelper.getActiveEditorText()
    filePath = AtomHelper.getActiveEditor().getPath()
    metaFilePath = "#{filePath}.meta.json"
    fs.readFile metaFilePath, 'utf8', (err, data) ->
      if err
        alert "Metadata error: #{err}"
        return

      metadata = JSON.parse data

      service = null
      switch(metadata.type)
        when 'class'
          service = new ApexClassService(accessToken)
        when 'trigger'
          service = new ApexTriggerService(accessToken)
        when 'component'
          service = new ApexComponentService(accessToken)
        when 'page'
          service = new ApexPageService(accessToken)

      mcs = new MetadataContainerService(accessToken)
      mcs.saveEntity metadata.type, metadata.id, fileContents, (result) ->
        loader.remove()
        console.log "DONE: %j", result
        if result.success
          AtomHelper.saveActiveItem()
          alert 'All your codez are good'
        else
          alert "Your codez are bad:\n#{result.compilerErrors[0].problem}\nLine: #{result.compilerErrors[0].line}"

  refreshCurrentFile: ->
    self = this

    accessToken = self.getAccessToken()

    if not confirm("This will overwrite any changes you made. Are you sure?")
      return

    loader = self.getAsyncLoader('Getting you a fresh, new copy...')
    loader.show()

    MetadataFileHelper.getMetadataForActiveFile (err, metadata) ->
      if err
        loader.remove()
        alert "Error opening metadata file:\n\n#{err}"
        return

      service = null
      switch metadata.type
        when 'class'
          service = new ApexClassService(accessToken)
        when 'trigger'
          service = new ApexTriggerService(accessToken)
        when 'component'
          service = new ApexComponentService(accessToken)
        when 'page'
          service = new ApexPageService(accessToken)

      if not service
        loader.remove()
        alert "Invalid type specified in metadata file!"
        return

      service.retrieve metadata.id, (record) ->
        loader.remove()
        AtomHelper.setActiveEditorText(record[service.sobjectContentField])
        AtomHelper.saveActiveItem()

  deleteCurrentFile: ->
    self = this
    if not confirm("This will delete the class from SFDC servers. Are you sure?")
      return

    # Get the path early in case user changes tabs while delete operation
    # is in progress
    filePath = AtomHelper.getActiveEditor().getPath()

    loader = self.getAsyncLoader('Deleting...')
    loader.show()

    accessToken = self.getAccessToken()
    MetadataFileHelper.getMetadataForActiveFile (err, metadata) ->
      if err
        loader.remove()
        alert "Error opening metadata file:\n\n#{err}"
        return

      service = null
      switch metadata.type
        when 'class'
          service = new ApexClassService(accessToken)
        when 'trigger'
          service = new ApexTriggerService(accessToken)
        when 'component'
          service = new ApexComponentService(accessToken)
        when 'page'
          service = new ApexPageService(accessToken)

      if not service
        loader.remove()
        alert "Invalid type specified in metadata file!"
        return


      removeFile = (err, remoteDeleted) ->
        fs.unlink filePath, (err) ->
          if err
            alert "Error deleting file locally:\n\nerr"
            return
          removeMetadataFile()

      removeMetadataFile = ->
        fs.unlink "#{filePath}.meta.json", (err) ->
          if err
            alert "Error deleting metadata file:\n\nerr"
        loader.remove()

      # Delete record on server and local
      service.deleteRecord metadata.id, removeFile
