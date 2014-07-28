fsPlus = require 'fs-plus'
fs = require 'fs'
Logger = require './logger'

module.exports =
class MetadataFileHelper

  this.getMetadataForActiveFile = (cb) ->
    editor = atom.workspace.activePaneItem
    filePath = editor.getPath()
    metaFilePath = "#{filePath}.meta.json"
    Logger.info '', metaFilePath
    fs.readFile metaFilePath, 'utf8', (err, data) ->
      if err
        cb(err, null)
        return

      try
        metadata = JSON.parse data
        cb(null, metadata)
      catch e
        cb(e, null)
