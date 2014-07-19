BaseToolingService = require './base-tooling-service'

module.exports =
class ApexTriggerService extends BaseToolingService

  constructor: (token) ->
    super(token)
    @sobjectType = 'ApexTrigger'

  retrieveAll: (cb) ->
    self = this
    records = []

    handleResult = (data, response) ->
      console.log data
      console.log "Received #{data.records.length} records"
      for record in data.records
        records.push record

      if not data.done
        BaseToolingService.prototype.get.apply self, ["query/#{data.queryLocator}", null, handleResult]
      else
        cb(records)

    select = "Select+Id,Name,Status,Body,BodyCrc,ApiVersion,LastModifiedDate,LastModifiedById"
    from = "from+#{@sobjectType}"
    where = "where%20NamespacePrefix%20%3D%20null"
    orderBy = "order by Name"
    @get 'query', "q=#{select}+#{from}+#{where}+#{orderBy}", handleResult
