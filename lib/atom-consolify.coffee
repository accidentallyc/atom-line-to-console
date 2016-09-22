{CompositeDisposable} = require 'atom'
rxChk = /^console\.log\(\".*\"\,(.*)\)$/
module.exports =
  subscriptions: null

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'line-to-console': @consolifyFn
  deactivate: ->
    @subscriptions.dispose()
  consolifyFn: (event)->
    editor  = atom.workspace.getActiveTextEditor()
    file    = editor.getFileName()

    editor.selections.forEach (sel)->
      sel.cursor.moveToEndOfLine()
      sel.selectToFirstCharacterOfLine()

      orig  = sel.getText()# -- orig = sel.getText()
      ln    = sel.getTailBufferPosition().row + 1

      match = orig.match(rxChk)
      # If already consoled then swap back to the regular one
      if match && match.length
        text = RegExp.$1
      else # If not consoled then we rewrite it as a console
        text = "console.log(\"#{file}:#{ln} ::\",#{orig})"

      sel.insertText(text)
