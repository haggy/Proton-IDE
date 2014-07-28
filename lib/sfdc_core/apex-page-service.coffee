BaseToolingService = require './base-tooling-service'

module.exports =
class ApexPageService extends BaseToolingService

  constructor: (token) ->
    super(token)
    @sobjectType = 'ApexPage'
    @sobjectContentField = 'Markup'
    @requiredCreateFields =
      Name:"Name"
      MasterLabel: "Label"
      Markup: "Page content"
    @fileExtension = 'page'
    @defaultFolder = 'pages'

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

    select = "Select Id,Markup,Name,ApiVersion,LastModifiedDate,LastModifiedById"
    from = "from #{@sobjectType}"
    where = "where NamespacePrefix = null"
    orderBy = "order by Name"
    @get 'query', "q=#{select} #{from} #{where} #{orderBy}", handleResult

  getDefaultCreateContent: ->
    return "<apex:page>\n\n</apex:page>"
