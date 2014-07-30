Config = require '../helpers/config'
AtomHelper = require '../helpers/atom-helper'
ProtonHelper = require '../helpers/proton-helper'
AsyncLoaderView = require '../async-loader-view'
Logger = require '../helpers/logger'

module.exports =
class BaseController

  constructor: (@view) ->
    @token = null

  # getAccessToken: ->
  #   if @token
  #     return @token
  #   else
  #     @token = Config.read('token')
  #     if @token
  #       return @token
  #     else
  #       alert "You must be logged in for this action!"
  #       return null
  getAccessToken: ->
    token = Config.read('token')
    if token
      return token
    else
      alert "You must be logged in for this action!"
      return null

  clearToken: ->
    @token = null
    @logInfo "Token cleared.. "

  getAsyncLoader: (text = 'Loading some complicated codez...')->
    if not @asyncLoader
      @asyncLoader = new AsyncLoaderView loadingText: text
      atom.workspaceView.append(@asyncLoader)
    else
      @asyncLoader.setLoadingText(text)
    return @asyncLoader

  logInfo: (str, obj) ->
    Logger.info(str, obj)

  logWarn: (str, obj) ->
    Logger.warn(str, obj)

  logError: (str, obj) ->
    Logger.error(str, obj)

  isErrorResult: (res) ->
    # In salesforce REST, an Array with 1 element will be returned when
    # an error ocurrs
    return ProtonHelper.isArray res

  getErrorFromResult: (res) ->
    if not @isErrorResult res then return null
    return "#{res[0].errorCode}: #{res[0].message}"
