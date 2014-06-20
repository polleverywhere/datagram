window.Results = (I={}) ->
  self =
    queryRows: Observable []
    filteredRows: Observable []
    queryColumns: Observable []
    filteredColumns: Observable []
    rows: ->
      if self.filteredRows().length
        self.filteredRows.map (row) ->
          for k, v of row
            obj = {}
            obj[k] = $("<span>#{v}</span>").get(0)
      else
        self.queryRows()
    columns: ->
      if self.filteredRows().length
        self.filteredColumns()
      else
        self.queryColumns()
    hasResults: ->
      self.queryRows().length || self.filteredRows().length
    classes:
      download: ->
        "display-none" unless self.hasResults()
      sql: ->
        "display-none" unless self.queryRows().length
      filter: ->
        "display-none" unless self.filteredRows().length
    downloadDisabled: ->
      "disabled" unless self.hasResults()
    downloadPath: ->
      return unless activeQuery()
      activeQuery().text.downloadPath()
    sqlCount: ->
      self.queryRows().length
    filterCount: ->
      self.filteredRows().length

  self
