/*
 * WYMeditor : what you see is What You Mean web-based editor
 * Copyright (c) 2005 - 2009 Jean-Francois Hovinne, http://www.wymeditor.org/
 * Dual licensed under the MIT (MIT-license.txt)
 * and GPL (GPL-license.txt) licenses.
 *
 * For further information visit:
 *        http://www.wymeditor.org/
 *
 * File Name:
 *        jquery.wymeditor.opera.js
 *        Opera specific class and functions.
 *        See the documentation for more info.
 *
 * File Authors:
 *        Jean-Francois Hovinne (jf.hovinne a-t wymeditor dotorg)
 */


WYMeditor.WymClassOpera = function(wym) {

    this._wym = wym;
    this._class = "class";
    this._newLine = "\r\n";
};

WYMeditor.WymClassOpera.prototype.initIframe = function(iframe) {

    this._iframe = iframe;
    this._doc = iframe.contentWindow.document;

    //add css rules from options
    var styles = this._doc.styleSheets[0];
    var aCss = eval(this._options.editorStyles);

    this.addCssRules(this._doc, aCss);

    this._doc.title = this._wym._index;

    //set the text direction
    $('html', this._doc).attr('dir', this._options.direction);

    //init designMode
    this._doc.designMode = "on";

    //init html value
    this.html(this._wym._html);

    //pre-bind functions
    if($.isFunction(this._options.preBind)) this._options.preBind(this);

    //bind external events
    this._wym.bindEvents();

    //bind editor keydown events
    $(this._doc).bind("keydown", this.keydown);

    //bind editor events
    $(this._doc).bind("keyup", this.keyup);

    // bind paste events for when this is supported.
    $(this._doc).bind("paste", this.intercept_paste);

    //post-init functions
    if($.isFunction(this._options.postInit)) this._options.postInit(this);

    //add event listeners to doc elements, e.g. images
    this.listen();
};

WYMeditor.WymClassOpera.prototype._exec = function(cmd,param) {
  if(param) this._doc.execCommand(cmd,false,param);
  else this._doc.execCommand(cmd);
};

WYMeditor.WymClassOpera.prototype.selected = function() {
  var sel=this._iframe.contentWindow.getSelection();
  var node=sel.focusNode;
  if(node) {
    if(node.nodeName=="#text") {
      return(node.parentNode);
    }
    else {
      return(node);
    }
  } else {
    return(null);
  }
};

WYMeditor.WymClassOpera.prototype.addCssRule = function(styles, oCss) {
  styles.insertRule(oCss.name + " {" + oCss.css + "}", styles.cssRules.length);
};

//keydown handler
WYMeditor.WymClassOpera.prototype.keydown = function(e) {

  //'this' is the doc
  var wym = WYMeditor.INSTANCES[this.title];
  var sel = wym._iframe.contentWindow.getSelection();
  startNode = sel.getRangeAt(0).startContainer;

  //Get a P instead of no container
  if(!$(startNode).parentsOrSelf(WYMeditor.MAIN_CONTAINERS.join(","))[0]
      && !$(startNode).parentsOrSelf('li')
      && e.keyCode != WYMeditor.KEY.ENTER
      && e.keyCode != WYMeditor.KEY.LEFT
      && e.keyCode != WYMeditor.KEY.UP
      && e.keyCode != WYMeditor.KEY.RIGHT
      && e.keyCode != WYMeditor.KEY.DOWN
      && e.keyCode != WYMeditor.KEY.BACKSPACE
      && e.keyCode != WYMeditor.KEY.DELETE)
      wym._exec(WYMeditor.FORMAT_BLOCK, WYMeditor.P);

};

//keyup handler
WYMeditor.WymClassOpera.prototype.keyup = function(e) {

  //'this' is the doc
  var wym = WYMeditor.INSTANCES[this.title];
  wym._selected_image = null;
  $(wym._iframe).contents().find('.selected_by_wym').removeClass('selected_by_wym');
};
