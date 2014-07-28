Config = require './config'

module.exports =
class Logger

  debugEnabled = Config.read('debug') is '1'

  this.info = (str, obj) ->
    if debugEnabled
      console.info "INFO: #{str}"
      if obj? then console.info obj

  this.warn = (str, obj) ->
    if debugEnabled
      console.warn "WARN: #{str}"
      if obj? then console.warn obj

  this.error = (str, obj) ->
    if debugEnabled
      console.error "ERROR: #{str}"
      if obj? then console.error obj
