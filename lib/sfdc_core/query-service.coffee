Client = require('node-rest-client').Client
Logger = require '../helpers/logger'
Config = require '../helpers/config'
ProtonHelper = require '../helpers/proton-helper'
{$} = require 'atom'

module.exports =
class QueryService

  constructor: (@token) ->
    domain = Config.read('domain')
    apiVersion = Config.read('api_version')
    @baseUrl = "#{domain}/services/data/v#{apiVersion}/query"
    @updateBaseUrl = "#{domain}/services/data/v#{apiVersion}/sobjects"
    @client = new Client()

  getDefaultHeaders: ->
    'Authorization': "Bearer #{@token}",
    'Content-Type': 'application/json'

  get: (params, cb) ->
    endpoint = "#{@baseUrl}?q=#{params}"
    reqParams =
      headers: this.getDefaultHeaders()

    Logger.info endpoint
    Logger.info '', reqParams
    @client.get endpoint, reqParams, cb


  query: (select, from, where, cb) ->
    whereStr = if where then "where #{where}" else ""
    strQuery = "select #{select} from #{from} #{whereStr}"
    Logger.info "Exec query = #{strQuery}"

    @get strQuery, (data, response) =>
      Logger.info '', data
      Logger.info '', response

      if @isErrorResult data
        errMsg = @getErrorFromResult(data)
        cb errMsg, null
        return

      resArray = []
      for record in data.records
        resArray.push @cleanObject(record)


      cb(null, resArray)

  cleanObject: (obj) ->
    cleanObj = {}

    for key, val of obj
      if not obj.hasOwnProperty key then continue
      if key.toLowerCase() is 'attributes' then continue

      type = ProtonHelper.getSimpleType obj[key]

      if type isnt 'object'
        # need lowercase name for table libs
        cleanObj[key.toLowerCase()] = val
      else
        outObj = {}
        @parseObjectsForTable obj[key], key, outObj
        $.extend cleanObj, outObj

    return cleanObj

  save: (type, id, data, cb) ->
    endpoint = "#{@updateBaseUrl}/#{type}/#{id}"

    if data.id then delete data.id

    reqParams =
      data: data
      headers: @getDefaultHeaders()

    Logger.info endpoint
    Logger.info '', reqParams
    @client.patch endpoint, reqParams, (data, response) ->
      cb(data)

  isErrorResult: (res) ->
    # In salesforce REST, an Array with 1 element will be returned when
    # an error ocurrs
    return ProtonHelper.isArray res

  getErrorFromResult: (res) ->
    if not @isErrorResult res then return null
    return "#{res[0].errorCode}: #{res[0].message}"

  parseObjectsForTable: (obj, currName, outObj) ->
    currName = if currName? then currName else null

    for key, val of obj
      if not obj.hasOwnProperty key then continue
      lowerKey = key.toLowerCase()
      if lowerKey is 'id' or lowerKey is 'attributes' then continue

      type = ProtonHelper.getSimpleType obj[key]
      fieldName = if currName? then "#{currName}.#{key}" else key

      if type isnt 'object'
        outObj[fieldName.toLowerCase()] = obj[key]
      else
        @parseObjectsForTable obj[key], fieldName, outObj
