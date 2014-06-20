(window.JST || (window.JST = {}))['schema'] = 
(function(data) {
  return (function() {
    var __runtime;
    __runtime = Runtime(this);
    __runtime.push(document.createDocumentFragment());
    __runtime.push(document.createElement("div"));
    __runtime.classes("schema", this["class"]);
    __runtime.push(document.createElement("div"));
    __runtime.classes("columns");
    __runtime.each(this.schema, function(data) {
      __runtime.push(document.createElement("div"));
      __runtime.classes("database-table");
      __runtime.push(document.createElement("h4"));
      __runtime.classes("table-name");
      __runtime.text(data[0]);
      __runtime.pop();
      __runtime.push(document.createElement("ul"));
      __runtime.classes("table-columns");
      __runtime.each(data[1], function(col) {
        __runtime.push(document.createElement("li"));
        __runtime.text(col);
        return __runtime.pop();
      });
      __runtime.pop();
      return __runtime.pop();
    });
    __runtime.pop();
    __runtime.pop();
    return __runtime.pop();
  }).call(data);
});
