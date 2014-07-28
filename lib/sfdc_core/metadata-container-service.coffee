BaseToolingService = require './base-tooling-service'
async = require 'async'

module.exports =
class MetadataContainerService extends BaseToolingService

  constructor: (token) ->
    super(token)
    @sobjectType = 'MetadataContainer'
    @containerRef = null
    @defaultContainerName = 'SfdcNeutrinoContainer'

  create: (contName, cb) ->
    service = 'sobjects/MetadataContainer/'
    params = name: contName

    onResult = (data, response) ->
      @logInfo '', data
      @logInfo '', response
      self.containerRef = data.records[0]
      cb(data)

    @post service, params, onResult

  retrieve: (contId, cb) ->
    self = this
    service = "sobjects/MetadataContainer/#{contId}"
    onResult = (data, response) ->
      @logInfo '', data
      @logInfo '', response
      self.containerRef = data.records[0]
      cb(data)
    @get service, null, onResult

  retrieveByName: (contName, cb) ->
    self = this
    service = 'query'
    params = "q=Select+id,Name+from+MetadataContainer+where+Name='#{@defaultContainerName}'"
    onResult = (data, response) ->
      self.logInfo '', data
      if data.size is 1
        self.containerRef = data.records[0]
        cb(self.containerRef)
      else
        cb(null)

    @get service, params, onResult


  saveMember: (memberType, memberReqData, cb) ->
    @post "sobjects/#{memberType}", memberReqData, (data, response) ->
      @logInfo '', data
      @logInfo '', response
      cb(data)

  containerAsyncRequest: (asyncReqData, cb) ->
    @post "sobjects/ContainerAsyncRequest", asyncReqData, (data, response) ->
      @logInfo '', data
      @logInfo '', response
      cb(data)

  saveEntity: (type, entityId, content, deployedCb) ->
    self = this
    containerAsyncReqId = null
    entitySaveMemberId = null

    if not @containerRef
      self.logInfo 'No container ref!'
      async.series [
        (next) ->
          self.logInfo 'Loading container'
          self.retrieveByName self.defaultContainerName, (cont) ->
            if not cont
              self.create self.defaultContainerName, (createRes) ->
                next null, createRes.Id
            else
              self.logInfo "Passing container...#{cont.Id}"
              next null, cont.Id
        ,(next) ->
          self.logInfo "Creating entity member request..#{self.containerRef.Id}, #{entityId}"
          entitySaveInfo = self.getEntityInfoByType(type)

          apexMemberRequest =
            MetadataContainerId: self.containerRef.Id
            ContentEntityId: entityId
          apexMemberRequest[entitySaveInfo.contentField] = content

          self.saveMember entitySaveInfo.toolingApiMemberName,
            JSON.stringify(apexMemberRequest),
            (result) ->
              self.logInfo "AT saveMember", result
              entitySaveMemberId = result.id
              next null, result

        ,(next) ->

          containerAsyncReqData =
            MetadataContainerId: self.containerRef.Id
            isCheckOnly: false

          self.containerAsyncRequest containerAsyncReqData, (result) ->
            self.logInfo '', result
            #containerAsyncReqId = result.Id
            self.checkOnDeploy result.id, (deployResults) ->
              self.logInfo "DEPLOY RESULT:", deployResults
              cbResultObj =
                compilerErrors: JSON.parse deployResults.CompilerErrors
                errorMsg: deployResults.ErrorMessage ?= ''
                testsRun: deployResults.IsRunTests
                sysModstamp: deployResults.SystemModstamp
              cbResultObj.success = cbResultObj.compilerErrors.length is 0

              if not cbResultObj.success
                # We need to delete the Apex member request or else
                # we will get duplication errors when we try to save
                # the file again
                self.logInfo "Deleting entity member #{entitySaveMemberId}"
                entitySaveInfo = self.getEntityInfoByType(type)
                self.deleteApexEntityMember entitySaveInfo.toolingApiMemberName, entitySaveMemberId, (delResult) ->
                  self.logInfo "Deleted entity member #{delResult}"

              deployedCb(cbResultObj)
      ]

  checkOnDeploy: (contAsyncReqId, cb) ->
    self = this
    intervalId = -1
    @logInfo "Checking on deploy #{contAsyncReqId}"

    timedCheck = (deployRes) =>
      @logInfo deployRes
      if deployRes.State isnt 'Queued'
        clearInterval intervalId
        cb(deployRes)

    intervalId = setInterval ->
      BaseToolingService.prototype.get.apply self, ["sobjects/ContainerAsyncRequest/#{contAsyncReqId}", null, timedCheck]
    , 5000

  getEntityInfoByType: (type) ->
    switch type
      when 'class'
        return contentField: 'Body', toolingApiMemberName: 'ApexClassMember'
      when 'page'
        return contentField: 'Body', toolingApiMemberName: 'ApexPageMember'
      when 'trigger'
        return contentField: 'Body', toolingApiMemberName: 'ApexTriggerMember'
      when 'component'
        return contentField: 'Body', toolingApiMemberName: 'ApexComponentMember'

  deleteApexEntityMember: (type, id, cb) ->
    @delete "sobjects/#{type}/#{id}", null, cb
