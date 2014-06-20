debounce = (func, threshold=100) ->
  timeout = null

  (args...) ->
    obj = this

    delayed = ->
      func.apply(obj, args)
      timeout = null

    clearTimeout(timeout) if timeout
    timeout = setTimeout delayed, threshold

saving = Observable(false)
saved = Observable(true)
unsaved = Observable(false)

window.Query = (I={}) ->
  self =
    update: (data={}) ->
      $.ajax
        type: "PUT"
        url: "/queries/#{self.id()}"
        data: data
        dataType: "json"

    destroy: ->
      $.ajax
        type: "DELETE"
        url: "/queries/#{self.id()}"
        dataType: "json"

    run: ->
      unless self.locked() || (/LIMIT/ig).test(self.content())
        self.content(self.content() + "\nLIMIT 100")
        resetEditorSql(self.content())

      # save first to persist latest editor changes, then
      # run on server to prevent sending the query over http
      self.save().then ->
        $.ajax
          type: "GET"
          url: "/queries/#{self.id()}/run"
          dataType: "json"

    save: ->
      if self.locked()
        # noop promise
        $.Deferred().resolve()
      else
        saving(true)
        unsaved(false)

        self.update(self.toJSON()).done ->
          saving(false)
          saved(true)

    toJSON: ->
      {
        name: I.name
        content: I.content
        description: I.description
        filter: I.filter
        folder_id: I.folder_id
        locked_at: I.locked_at
      }

    activate: ->
      activeQuery(self)

    disabled: ->
      self.locked()

    lock: ->
      if self.locked()
        self.locked_at(null)
      else
        self.locked_at(new Date)

    locked: ->
      !!self.locked_at()

    text:
      description: ->
        if self.locked()
          ""
        else
          "What does this query do?"

      downloadPath: ->
        "/queries/#{self.id()}/download"

      lockedAlt: ->
        if self.locked()
          "Locked from modifications at #{self.locked_at()}"
        else
          "Lock query"

      unsaved: "Unsaved query changes"
      saved: "Query successfully saved"
      saving: "Saving query"

    classes:
      active: ->
        "active" if active()

      disabled: ->
        "disabled" if self.locked()

      editTitle: ->
        "display-none" unless active()

      hideWhenActive: ->
        "display-none" if active()

      showTitle: ->
        "display-none" if active()

      locked: ->
        "locked" if self.locked()

      unsaved: ->
        "unsaved" if unsaved()

      saving: ->
        "saving" if saving()

      saved: ->
        "saved" if saved()

  # Observe I properties
  Object.keys(I).forEach (name) ->
    self[name] = Observable(I[name])

    self[name].observe (newValue) ->
      I[name] = newValue

  debouncedSave = debounce(self.save, 1000)

  active = ->
    activeQuery() && self.id() is activeQuery().id()

  [
    "name"
    "filter"
    "content"
    "description"
  ].forEach (attr) ->
    self[attr].observe ->
      saved(false)
      unsaved(true)
      debouncedSave()

  self.locked_at.observe (val) ->
    self.update(self.toJSON())

    enableEditor() if activeQuery().id() is self.id()

  self.folder.observe (folder) ->
    id = folder.id()
    id = null if id < 0

    self.folder_id(id)
    self.update(self.toJSON())

    folders.forEach (f) ->
      f.queries.remove(self)
      folder.expanded(false) unless f.queries().length

    folder.queries.push(self)
    folder.expanded(true)

    self.activate()

  Query.create = ->
    $.ajax
      type: "POST"
      url: "/queries"
      dataType: "json"

  self