(window.JST || (window.JST = {}))['error'] = 
(function(data) {
  return (function() {
    var __runtime;
    __runtime = Runtime(this);
    __runtime.push(document.createDocumentFragment());
    __runtime.push(document.createElement("div"));
    __runtime.classes("error-message", this.shown);
    __runtime.push(document.createElement("div"));
    __runtime.classes("text");
    __runtime.text(this.error);
    __runtime.pop();
    __runtime.push(document.createElement("div"));
    __runtime.classes("icon-remove");
    __runtime.attribute("click", this.hide);
    __runtime.pop();
    __runtime.pop();
    return __runtime.pop();
  }).call(data);
});
