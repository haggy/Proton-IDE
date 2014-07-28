# Class for performing common atom operations

module.exports =
class AtomHelper

  this.getActiveEditor = ->
    return atom.workspace.activePaneItem

  this.getActivePane = ->
    return atom.workspace.getActivePane()

  this.getActiveEditorText = ->
    return this.getActiveEditor().getText()

  this.setActiveEditorText = (text) ->
    this.getActiveEditor().setText(text)

  this.saveActiveItem = ->
    this.getActivePane().saveActiveItem()

  this.getProjectPath = ->
    return atom.project.getPath()
