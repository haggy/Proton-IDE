Client = require('node-rest-client').Client
Logger = require('../helpers/logger')

module.exports =
  class SfdcAuthService
    this.loginUrl = 'https://login.salesforce.com/services/oauth2/token'
    this.sandboxUrl = 'https://test.salesforce.com/services/oauth2/token'
    this.client = new Client()
    this.clientId = '3MVG9A2kN3Bn17hsLDHMrMDqllnmSqumg.coZfp22GoWQBtuiXoDV9eEwGJLLKbbxFiaGlI04u.H66C.U3Tx1'
    this.clientSecret = '1422013648596648433'

    this.login = (env, uname, pass, cb) ->
      self = this

      # Splits the user ID off of a return URL during login call
      splitUserIdFromUrl = (url) ->
        parts = url.split('/');
        return parts.pop()

      params =
        # data:
        #   grant_type: 'password'
        #   username: uname.replace('@', '%40')
        #   password: pass
        #   client_secret: this.clientSecret
        #   client_id: this.clientId
        data: "client_id=3MVG9A2kN3Bn17hsLDHMrMDqllnmSqumg.coZfp22GoWQBtuiXoDV9eEwGJLLKbbxFiaGlI04u.H66C.U3Tx1&client_secret=1422013648596648433&password=#{pass}&username=#{uname}&grant_type=password"
        headers:
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'

      url = null
      if env is 'sandbox'
        url = this.sandboxUrl
      else
        url = this.loginUrl

      self.client.post url, params, (data, response) =>
        if data.error_description
          Logger.error data.error_description
          cb(false, data.error_description, null, null)
          return

        Logger.info "TOKEN: #{data.access_token}"
        userId = splitUserIdFromUrl(data.id)
        cb(true, data.access_token, data.instance_url, userId)

    this.joinParams = (params) ->
      paramStr = ''
      for key, val of params
        paramStr += key + val + '&'

      paramStr
