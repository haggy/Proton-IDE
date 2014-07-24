BaseToolingService = require './base-tooling-service'

module.exports =
class ApexClassService extends BaseToolingService

  constructor: (token) ->
    super(token)
    @sobjectType = 'ApexClass'
    @requiredCreateFields =
      Name:"Name"
      Body: "Class Body"
    @fileExtension = 'cls'
    @defaultFolder = 'classes'

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

    select = "Select Id,Body,Name,BodyCrc,ApiVersion,Status,LastModifiedDate,LastModifiedById"
    from = "from #{@sobjectType}"
    where = "where NamespacePrefix = null"
    orderBy = "order by Name"
    @get 'query', "q=#{select} #{from} #{where} #{orderBy}", handleResult

  getDefaultCreateContent: (params) ->
    return "public class #{params.Name} {\n\n}"
