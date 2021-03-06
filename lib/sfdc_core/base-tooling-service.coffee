# The base class for all tooling API requests
fsPlus = require 'fs-plus'
Config = require '../helpers/config'
Client = require('node-rest-client').Client
ProtonHelper = require '../helpers/proton-helper'
Logger = require '../helpers/logger'

module.exports =
class BaseToolingService

  constructor: (token) ->
    @token = token
    # REST API object name (ApexClass, ApexTrigger etc..)
    @sobjectType = null
    # File extension
    @fileExtension = null
    # Default folder to store this metadata type
    @defaultFolder = null
    # An object containing require field API Name -> Label
    # Ex: Name:"Name"
    #     Markup: "Page Markup"
    #     MasterLabel: "Label"
    @requiredCreateFields = {}
    # The content field for the sobject
    # This is usually either Body or Markup
    @sobjectContentField = 'Body'

    domain = Config.read('domain')
    if not domain
      throw new Error('SFDC base domain is not set. Please login first!')

    @apiVersion = Config.read('api_version')
    @toolingBaseUrl = "#{domain}/services/data/v#{this.apiVersion}/tooling/"

    @client = new Client()

  logInfo: (str, obj) ->
    Logger.info(str, obj)

  logWarn: (str, obj) ->
    Logger.warn(str, obj)

  logError: (str, obj) ->
    Logger.error(str, obj)

  getDefaultHeaders: ->
    'Authorization': "Bearer #{@token}",
    'Content-Type': 'application/json'

  get: (service, params, cb) ->
    endpoint = "#{@toolingBaseUrl}#{service}?#{params}"
    params =
      headers: this.getDefaultHeaders()

    @logInfo endpoint
    @logInfo '', params
    @client.get endpoint, params, (data, response) =>
      @logInfo "BaseToolingService GET response:", data
      cb(data, response)

  post: (service, params, cb) ->
    endpoint = "#{@toolingBaseUrl}#{service}"
    postParams =
      data: params
      headers: this.getDefaultHeaders()

    @logInfo endpoint
    @logInfo '', postParams
    @client.post endpoint, postParams, (data, response) =>
      @logInfo "BaseToolingService POST response:", data
      cb(data, response)

  delete: (service, params, cb) ->
    endpoint = "#{@toolingBaseUrl}#{service}"
    postParams =
      headers: this.getDefaultHeaders()

    @logInfo endpoint
    @logInfo '', postParams
    @client.delete endpoint, postParams, cb

  getById: (type, id, cb) ->
    service = "sobjects/#{type}/#{id}"
    @get service, null, cb

  retrieve: (id, cb) ->
    @getById this.sobjectType, id, (data, response) ->
      cb(data)


  # Should return the default content for object creation
  # Override in child classes to return the object specific content
  getDefaultCreateContent: ->
    return null

  create: (params, cb) ->
    self = this
    # Check that required fields config has been set
    if Object.keys(@requiredCreateFields).length == 0
      cb('Params cannot be empty', null)
      return

    params[@sobjectContentField] = self.getDefaultCreateContent(params)

    # Check that all required fields have been set
    # and setup post params
    postParams = {}
    for key, val of @requiredCreateFields
      if not params[key]
        cb("Required field #{key} is missing", null)
        return
      postParams[key] = params[key]

    @logInfo '', postParams
    self.post "sobjects/#{@sobjectType}", postParams, (data, response) ->

      if ProtonHelper.isArray(data) and data[0].errorCode
        switch(data[0].errorCode)
          when 'DUPLICATE_VALUE'
            cb("Object already exists on the server", null)
          when 'INVALID_SESSION_ID'
            cb("Please login first (Proton->New Project->Connect)", null)
          else
            cb("Unknown error while creating object: #{data[0].errorCode}", null)

        return

      newId = data.id
      projPath = atom.project.getPath()
      fileName = "#{params.Name}.#{self.fileExtension}"
      fullPath = "#{projPath}/#{self.defaultFolder}/#{fileName}"
      content = params[self.sobjectContentField]
      fsPlus.writeFile fullPath, content, null, ->
        metaFileName = fileName + '.meta.json'
        metaFilePath = "#{projPath}/#{self.defaultFolder}/#{metaFileName}"
        metadata =
          id: newId
          version: self.apiVersion
          type: params.type

        fsPlus.writeFile metaFilePath, JSON.stringify(metadata), null, ->
          cb(null, fullPath)

  deleteRecord: (id, cb) ->
    @delete "sobjects/#{@sobjectType}/#{id}", null, (data, response) ->
      cb(null, true)
