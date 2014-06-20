configureEditor = (selector, mode) ->
  editor = ace.edit(selector)
  editor.setTheme "ace/theme/tomorrow"
  editor.setShowPrintMargin(false)
  editor.renderer.setShowGutter(false)

  session = editor.session
  session.setMode "ace/mode/#{mode}"
  session.setTabSize(2)
  session.setUseSoftTabs(true)
  session.setUseWrapMode(true)
  session.setWrapLimitRange(null, null)

  editor

sqlEditor = configureEditor("sql-editor", "sql")
javascriptEditor = configureEditor("javascript-editor", "javascript")

$ ->
  window.enableEditor = ->
    if activeQuery().locked()
      sqlEditor.setReadOnly true
      sqlEditor.setTheme null
      sqlEditor.session.setMode null

      javascriptEditor.setReadOnly true
      javascriptEditor.setTheme null
      javascriptEditor.session.setMode null
    else
      sqlEditor.setReadOnly false
      sqlEditor.setTheme "ace/theme/tomorrow"
      sqlEditor.session.setMode "ace/mode/sql"

      javascriptEditor.setReadOnly false
      javascriptEditor.setTheme "ace/theme/tomorrow"
      javascriptEditor.session.setMode "ace/mode/javascript"

  hideErrorMessages = ->
    error("")

  $(document).on "keydown", (e) ->
    return unless e.keyCode is 27

    hideErrorMessages()

  $(document).on "click", (e) ->
    $target = $(e.target)

    return if $target.closest(".error-message").length

    hideErrorMessages()

  schemaHidden = Observable(true)
  error = Observable("")
  notice = Observable("")
  window.activeQuery = Observable()
  window.folders = Observable([])

  window.expandParentFolder = (query) ->
    folders.forEach (folder) ->
      if folderId = query.folder_id()
        folder.expanded(true) if folder.id() is folderId
      else
        folder.expanded(true) if folder.id() is -1

  activeQuery.observe (q) ->
    history?.pushState?({}, "#{q.name()}", "/queries/#{q.id()}")

    expandParentFolder(q)

    resetEditorSql(q.content())
    resetEditorFilter(q.filter())

    enableEditor()

  window.resetEditorSql = (sql) ->
    sqlEditor.removeListener "change", setActiveQuerySql

    sqlEditor.setValue(sql, 1)
    sqlEditor.getSession().setUndoManager(new ace.UndoManager)

    sqlEditor.on("change", setActiveQuerySql)

  window.resetEditorFilter = (filter) ->
    javascriptEditor.removeListener "change", setActiveQueryFilter

    javascriptEditor.setValue(filter, 1)
    javascriptEditor.getSession().setUndoManager(new ace.UndoManager)

    javascriptEditor.on("change", setActiveQueryFilter)

  setActiveQuerySql = ->
    activeQuery().content(sqlEditor.getValue())

  setActiveQueryFilter = ->
    activeQuery().filter(javascriptEditor.getValue())

  sqlEditor.on "change", setActiveQuerySql
  javascriptEditor.on "change", setActiveQueryFilter

  $.getJSON("/schema").done (data) ->
    $("#schema").template "schema",
      schema: ([tableName, columns] for tableName, columns of data)
      class: ->
        "hidden" if schemaHidden()

  $.getJSON("/folders").done (data) ->
    folders(data.map(Folder))

    if (id = parseInt(location.pathname.replace("/queries/", "")))
      activateQuery(id)
    else
      activateLastQuery()

    $("#title").template "title",
      name: ->
        activeQuery().name()

  lastQuery = ->
    last = null

    folder = folders.forEach (folder) ->
      last = folder.lastQuery() if folder.lastQuery()

    last

  activateQuery = (id) ->
    match = null

    folders.forEach (folder) ->
      folder.queries.forEach (q) ->
        match = q if q.id() is id

    if match
      activeQuery(match)
    else
      activateLastQuery()

  activateLastQuery = ->
    activeQuery(lastQuery())

  # put everything in the DOM
  $.fn.template = (name, data) ->
    $(this).append(JST[name](data))

  $("#error").template "error",
    error: error
    hide: ->
      hideErrorMessages()
    shown: ->
      "display-none" unless error().length

  $("#notice").template "notice",
    notice: notice
    shown: ->
      "display-none" unless notice().length

  $("#queries").template "queries",
    folders: folders
    delete: ->
      return unless activeQuery()
      return if activeQuery().locked()

      if confirm "Are you sure you want to delete '#{activeQuery().name()}'?"
        deferred = activeQuery().destroy()

        folder = folders()[0]
        folders.forEach (f) ->
          folder = f if f.id() is activeQuery().folder_id()

        deferred.done ->
          folder.queries.remove(activeQuery())
          activateLastQuery()

  resultsData = Results()

  $("#results").template "results", resultsData

  $("#commands").template "commands",
    schema: ->
      schemaHidden(!schemaHidden())
    runQuery: ->
      resultsData.queryRows []
      resultsData.queryColumns []

      resultsData.filteredRows []
      resultsData.filteredColumns []

      notice "Crunching some numbers"

      deferred = activeQuery().run()
      deferred.done (data) ->
        notice ""

        resultsData.queryColumns(data.columns)

        window.results = data.items
        resultsData.queryRows(data.items)

        if (filter = activeQuery().filter()).length
          try
            window.filtered = eval(filter)

            if filtered?
              resultsData.filteredColumns(Object.keys(window.filtered[0]))
              resultsData.filteredRows(filtered)
          catch e
            error "#{e.name}: #{e.message} in JavaScript filter. Make sure there are no typos in the filter pane."

      deferred.fail (response) ->
        notice ""

        try
          {message} = JSON.parse(response.responseText)

          error(message)

  $("#actions").template "actions",
    newFolder: ->
      if name = prompt("Name this folder", "New Folder")
        Folder.create(name).done (json) ->
          json.queries = []
          folder = Folder(json)
          folders.push(folder)

    newQuery: ->
      Query.create().done (json) ->
        # TODO clean this up
        ungrouped = null
        folders.forEach (folder) ->
          ungrouped = folder if folder.id() is -1

        json.folder = ungrouped.I
        query = Query(json)

        ungrouped.queries.push(query)
        activeQuery(query)
