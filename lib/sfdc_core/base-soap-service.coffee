soap = require 'soap'
xml2js = require('xml2js').parseString
AtomHelper = require '../helpers/atom-helper'
Logger = require '../helpers/logger'

WsdlData =
  '30':
    location: 'wsdl/apex-30.wsdl'

module.exports =
class BaseSoapService

  constructor: (token) ->
    @token = token
    # If true, debug info will be included in the response
    @debug = true

  logInfo: (str, obj) ->
    Logger.info(str, obj)

  logWarn: (str, obj) ->
    Logger.warn(str, obj)

  logError: (str, obj) ->
    Logger.error(str, obj)
    
  initClient: (cb) ->
    loc = "#{AtomHelper.getProjectPath()}/lib/#{WsdlData['30'].location}"
    soap.createClient loc, (err, client) =>
      @onClientCreate(err, client, cb)

  onClientCreate: (err, client, cb) ->
    if err?
      cb("Error with web services client: #{err}", null)

    @addDefaultHeaders(client)
    cb(null, client)

  addDefaultHeaders: (client) ->
    client.addSoapHeader { 'tns:SessionHeader': { 'tns:sessionId': @token } }

    if @debug
      debugHeader =  { 'tns:DebuggingHeader': {
        'tns:categories': [
          {'tns:category': 'Db', 'tns:level': 'DEBUG'},
          {'tns:category': 'Apex_profiling', 'tns:level': 'DEBUG'},
          {'tns:category': 'Apex_code', 'tns:level': 'DEBUG'},
          {'tns:category': 'Workflow', 'tns:level': 'DEBUG'}
        ]
      }}
      client.addSoapHeader debugHeader

  parseXml: (xml, cb) ->
    xml2js xml, (err, result) ->
      cb(result)

  parseDebugInfo: (xmlObj) ->
    debugArr = xmlObj['soapenv:Envelope']['soapenv:Header'][0].DebuggingInfo
    log = debugArr[0].debugLog[0]
    return log

  newlineToHtml: (str) ->
    return str.replace(/\n/g, '<br/>')
