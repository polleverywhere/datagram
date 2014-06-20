(window.JST || (window.JST = {}))['notice'] = 
(function(data) {
  return (function() {
    var __runtime;
    __runtime = Runtime(this);
    __runtime.push(document.createDocumentFragment());
    __runtime.push(document.createElement("div"));
    __runtime.classes("query-spinner", this.shown);
    __runtime.push(document.createElement("span"));
    __runtime.classes("text");
    __runtime.text(this.notice);
    __runtime.pop();
    __runtime.push(document.createElement("div"));
    __runtime.classes("icon-spinner", "icon-spin", "icon-large");
    __runtime.pop();
    __runtime.pop();
    return __runtime.pop();
  }).call(data);
});
