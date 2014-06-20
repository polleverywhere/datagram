(window.JST || (window.JST = {}))['actions'] = 
(function(data) {
  return (function() {
    var __runtime;
    __runtime = Runtime(this);
    __runtime.push(document.createDocumentFragment());
    __runtime.push(document.createElement("div"));
    __runtime.classes("btn-group");
    __runtime.push(document.createElement("button"));
    __runtime.classes("btn", "btn-default");
    __runtime.attribute("click", this.newQuery);
    __runtime.attribute("title", "Create a new query");
    __runtime.push(document.createElement("i"));
    __runtime.classes("icon-file");
    __runtime.pop();
    __runtime.pop();
    __runtime.push(document.createElement("button"));
    __runtime.classes("btn", "btn-default");
    __runtime.attribute("click", this.newFolder);
    __runtime.attribute("title", "Create a new folder");
    __runtime.push(document.createElement("i"));
    __runtime.classes("icon-folder-close-alt");
    __runtime.pop();
    __runtime.pop();
    __runtime.pop();
    return __runtime.pop();
  }).call(data);
});
