{View} = require 'atom'

window.$ = window.jQuery = require('jQuery')

module.exports =
class AsyncLoaderView extends View

  @content: (params) ->
    @div id: 'async-loader', class:'overlay from-bottom', =>
      @div class: 'async-loader-content', =>
        @img src: 'atom://sfdc/static/img/atom-blue_64.gif'
        @span "#{params.loadingText}", class: 'loader-text'

  setLoadingText: (text) ->
    this.find('span.loader-text').html(text)
