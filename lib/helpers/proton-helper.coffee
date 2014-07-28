rmdir = require 'rimraf'
Logger = require './logger'

module.exports =
class ProtonHelper

  # Returns true if the param is an array
  this.isArray = (obj) ->
    obj ?= ''
    return Object.prototype.toString.call(obj) is '[object Array]'

  # Recursively removes dir
  this.clearDirectory = (path, cb) ->
    Logger.info "Clearing path: #{path}"
    rmdir path, (err) ->
      if err
        Logger.error err
        cb(false)

      cb(true)
