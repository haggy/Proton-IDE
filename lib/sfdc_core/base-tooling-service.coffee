# The base class for all tooling API requests

Config = require '../helpers/config'
Client = require('node-rest-client').Client

module.exports =
class BaseToolingService
  this.apiVersion = Config.read('api_version')
  this.toolingBaseUrl = null

  constructor: (token) ->
    @token = token
    @sobjectType = null
    # The content field for the sobject
    # This is usually either Body or Markup
    @sobjectContentField = 'Body'

    if not this.apiVersion
      Config.write('api_version', '28.0')
      this.apiVersion = '28.0'

    domain = Config.read('domain')
    if not domain
      throw new Error('SFDC base domain is not set. Please login first!')

    this.toolingBaseUrl = "#{domain}/services/data/v#{this.apiVersion}/tooling/"

    @client = new Client()

  getDefaultHeaders: ->
    'Authorization': "Bearer #{@token}",'Content-Type': 'application/json'

  get: (service, params, cb) ->
    endpoint = "#{this.toolingBaseUrl}#{service}?#{params}"
    params =
      headers: this.getDefaultHeaders()

    console.log endpoint
    console.log params
    @client.get endpoint, params, cb

  post: (service, params, cb) ->
    endpoint = "#{this.toolingBaseUrl}#{service}"
    postParams =
      data: params
      headers: this.getDefaultHeaders()

    console.log endpoint
    console.log postParams
    @client.post endpoint, postParams, cb

  delete: (service, params, cb) ->
    endpoint = "#{this.toolingBaseUrl}#{service}"
    postParams =
      headers: this.getDefaultHeaders()

    console.log endpoint
    console.log postParams
    @client.delete endpoint, postParams, cb

  getById: (type, id, cb) ->
    service = "sobjects/#{type}/#{id}"
    @get service, null, cb

  retrieve: (id, cb) ->
    @getById this.sobjectType, id, (data, response) ->
      cb(data)
