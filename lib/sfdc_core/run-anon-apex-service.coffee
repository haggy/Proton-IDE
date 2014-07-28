# {
#   "line" : 2,
#   "column" : 0,
#   "compiled" : false,
#   "success" : false,
#   "compileProblem" : "expecting a semi-colon, found '<EOF>'",
#   "exceptionStackTrace" : null,
#   "exceptionMessage" : null
# }

BaseSoapService = require './base-soap-service'

module.exports =
class RunAnonApexService extends BaseSoapService

  constructor: (token) ->
    super(token)

  execute: (apex, cb) ->
    @initClient (err, client) =>
      client.executeAnonymous String: apex, (err, sfResult, body) =>
        @logInfo "Exec anonymous result:", sfResult
        if err?
          @logError err
          cb(err, null)
          return
        else if not sfResult.result.success
          errorStr = "#{sfResult.result.compileProblem}"
          cb(errorStr, sfResult.result)
          return

        if @debug
          @parseXml body, (xmlObj) =>
            debugInfo = @parseDebugInfo(xmlObj)
            result = sfResult.result
            result.debugInfo = @newlineToHtml(debugInfo)
            cb(null, result)
        else
          cb(null, sfResult.result)
