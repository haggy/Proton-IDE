
module.exports =
  class Config
    this.keyPath = 'sfdc.'

    this.read = (key) ->
      atom.config.get(this.keyPath + key)
    this.write = (key, val) ->
      atom.config.set(this.keyPath + key, val)
    this.delete = ->
