

module.exports =
class ProtonHelper

  # Returns true if the param is an array
  this.isArray = (obj) ->
    obj ?= ''
    return Object.prototype.toString.call(obj) is '[object Array]'
