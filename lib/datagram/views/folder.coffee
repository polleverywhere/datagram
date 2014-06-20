window.Folder = (I={}) ->
  self =
    I: I

    destroy: ->
      if self.id() is -1
        return alert "Ungrouped may not be deleted"

      if confirm "Are you sure you want to delete the folder '#{self.name()}'"
        folders.remove(self)

        $.ajax
          type: "DELETE"
          url: "/folders/#{self.id()}"
          dataType: "json"

        query = activeQuery()
        # HACK: reloading folders like this is pretty gross
        # but we want to make sure that the server is the source
        # of truth for folder -> query associations
        $.getJSON("/folders").done (data) ->
          folders(data.map(Folder))
          activeQuery(query)
          window.expandParentFolder(query)

    expanded: Observable(false)

    lastQuery: ->
      self.queries()[self.queries().length - 1]

    toggle: ->
      self.expanded(!self.expanded())

    text:
      nameAndCount: ->
        "#{self.name()} (#{self.queries().length})"

    classes:
      expanded: ->
        "expanded" if self.expanded()

    value: ->
      self.id()

  I.queries = I.queries.map (attrs) ->
    attrs.folder = self
    Query(attrs)

  # Observe I properties
  Object.keys(I).forEach (name) ->
    self[name] = Observable(I[name])

    self[name].observe (newValue) ->
      I[name] = newValue

  Folder.create = (name) ->
    $.ajax
      type: 'POST'
      url: '/folders'
      dataType: 'json'
      data:
        name: name

  self