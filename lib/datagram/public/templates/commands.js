(window.JST || (window.JST = {}))['commands'] = 
(function(data) {
  return (function() {
    var __runtime;
    __runtime = Runtime(this);
    __runtime.push(document.createDocumentFragment());
    __runtime.push(document.createElement("div"));
    __runtime.classes("btn-group", "commands");
    __runtime.push(document.createElement("button"));
    __runtime.classes("btn", "btn-default", "btn-schema");
    __runtime.attribute("click", this.schema);
    __runtime.attribute("title", 'Examine database schema');
    __runtime.push(document.createElement("i"));
    __runtime.classes("icon-table");
    __runtime.pop();
    __runtime.pop();
    __runtime.push(document.createElement("button"));
    __runtime.classes("btn", "btn-default", "btn-run");
    __runtime.attribute("click", this.runQuery);
    __runtime.attribute("title", 'Run this query');
    __runtime.push(document.createElement("i"));
    __runtime.classes("icon-play");
    __runtime.pop();
    __runtime.pop();
    __runtime.pop();
    return __runtime.pop();
  }).call(data);
});
