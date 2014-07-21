Config = require '../helpers/config'
AtomHelper = require '../helpers/atom-helper'
AsyncLoaderView = require '../async-loader-view'

module.exports =
class BaseController

  constructor: (@view) ->
    @token = null

  getAccessToken: ->
    if @token
      return @token
    else
      @token = Config.read('token')
      if @token
        return @token
      else
        alert "You must be logged in for this action!"
        return null

  getAsyncLoader: (text = 'Loading some complicated codez...')->
    if not @asyncLoader
      @asyncLoader = new AsyncLoaderView loadingText: text
      atom.workspaceView.append(@asyncLoader)
    else
      @asyncLoader.setLoadingText(text)
    return @asyncLoader
