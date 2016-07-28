/*
 * redrawKnob()
 * teeny tiny jquery plugin: adds a redraw method to knob
 * REQUIRES: jquery.knob
 * @austinpray 2013-09-29
 */
(function( $ ) {
  $.fn.redrawKnob = function( options ) {
    // defaults
    var settings = $.extend({
      inputClass: ".prof-pic-dial" // this is the default class stuck on your <input>
    }, options );
    //save input element, delete everything
    //add saved input element, call knob
    return this.each(function() {
      var $inputElem = $(this).find(settings.inputClass).clone();
      $(this)
        .empty()
        .append($inputElem)
        .find(settings.inputClass)
        .knob();
    });
  };
}( jQuery ));