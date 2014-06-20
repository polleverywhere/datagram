window.Editor = (I={}) ->
  editor = ace.edit(I.selector)
  editor.setTheme "ace/theme/tomorrow"
  editor.setShowPrintMargin(false)
  editor.renderer.setShowGutter(false)

  session = editor.session
  session.setMode "ace/mode/#{I.mode}"
  session.setTabSize(2)
  session.setUseSoftTabs(true)
  session.setUseWrapMode(true)
  session.setWrapLimitRange(null, null)

  self =
    disable: ->
      editor.setReadOnly true
      editor.setTheme null
      session.setMode null
    enable: ->
      editor.setReadOnly false
      editor.setTheme "ace/theme/tomorrow"
      session.setMode "ace/mode/#{I.mode}"
    reset: (value, changeFn) ->
      editor.removeListener "change", changeFn
      editor.setValue value, 1
      editor.getSession().setUndoManager(new ace.UndoManager)
      editor.on "change", changeFn
    change: (changeFn) ->
      editor.on "change", changeFn
    value: ->
      editor.getValue()
