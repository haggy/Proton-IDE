BaseToolingService = require './base-tooling-service'

module.exports =
class ApexComponentService extends BaseToolingService

  constructor: (token) ->
    super(token)
    @sobjectType = 'ApexComponent'
    @sobjectContentField = 'Markup'
    @requiredCreateFields =
      Name:"Name"
      MasterLabel: "Master Label"
      Markup: "Component Markup"
    @fileExtension = 'component'
    @defaultFolder = 'components'

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

    select = "Select Id,Markup,Name,ApiVersion,LastModifiedDate,LastModifiedById"
    from = "from #{@sobjectType}"
    where = "where NamespacePrefix = null"
    orderBy = "order by Name"
    @get 'query', "q=#{select} #{from} #{where} #{orderBy}", handleResult

  getDefaultCreateContent: ->
    return "<apex:component>\n\n</apex:component>"
