BaseToolingService = require './base-tooling-service'

module.exports =
class ApexTriggerService extends BaseToolingService

  constructor: (token) ->
    super(token)
    @sobjectType = 'ApexTrigger'
    @requiredCreateFields =
      Name:"Name"
      Body: "Trigger Body"
      TableEnumOrId: "Object type"
    @fileExtension = 'trigger'
    @defaultFolder = 'triggers'

  retrieveAll: (cb) ->
    self = this
    records = []

    handleResult = (data, response) =>
      @logInfo '', data
      @logInfo "Received #{data.records.length} records"
      for record in data.records
        records.push record

      if not data.done
        BaseToolingService.prototype.get.apply self, ["query/#{data.queryLocator}", null, handleResult]
      else
        cb(records)

    select = "Select Id,Name,Status,Body,BodyCrc,ApiVersion,LastModifiedDate,LastModifiedById"
    from = "from #{@sobjectType}"
    where = "where NamespacePrefix = null"
    orderBy = "order by Name"
    @get 'query', "q=#{select} #{from} #{where} #{orderBy}", handleResult

  getDefaultCreateContent: (params) ->
    objType = params.TableEnumOrId
    dmlConditions = "before insert, before update, before delete, after insert,"
    dmlConditions += " after update, after delete, after undelete"
    return "trigger #{params.Name} on #{objType} (#{dmlConditions}) {\n\n}"
