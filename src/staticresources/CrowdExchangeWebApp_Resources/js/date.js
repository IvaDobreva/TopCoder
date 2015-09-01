/*global angular */
/*
 jQuery UI Datepicker plugin wrapper

 @note If ≤ IE8 make sure you have a polyfill for Date.toISOString()
 @param [ui-date] {object} Options to pass to $.fn.datepicker() merged onto uiDateConfig
 */

angular.module('ui.date', [])

.constant('uiDateConfig', {})

.directive('uiDate', ['uiDateConfig', 'uiDateConverter', function (uiDateConfig, uiDateConverter) {
  'use strict';
  var options;
  options = {};
  angular.extend(options, uiDateConfig);
  return {
    require:'?ngModel',
    scope: {
        onDateChanged: '&?',
        minDate: '=',
        maxDate: '=',
        minOffset: '='
    },
    link:function (scope, element, attrs, controller) {
      var getOptions = function () {
        return angular.extend({}, uiDateConfig, scope.$eval(attrs.uiDate));
      };
      if(scope.minOffset===undefined){
        scope.minOffset = 0;
      }
      var setMinDate = function (value) {
          var newLimit = new Date(value);
          newLimit.setTime( newLimit.getTime() + scope.minOffset * 86400000);
          element.datepicker('option', 'minDate', newLimit);
          element.datepicker('refresh');
      }
      var setMaxDate = function (value) {
          var newLimit = new Date(value);
          newLimit.setTime( newLimit.getTime() + scope.minOffset * 86400000);
          element.datepicker('option', 'maxDate', newLimit);
          element.datepicker('refresh');
      }
      scope.$watch('minDate', function(value){
          setMinDate(value);
      });
      scope.$watch('maxDate', function(value){
          setMaxDate(value);
      });
      var initDateWidget = function () {
        var showing = false;
        var opts = getOptions();

        function setVal() {
          var keys = ['Hours', 'Minutes', 'Seconds', 'Milliseconds'],
              isDate = angular.isDate(controller.$modelValue),
              preserve = {};
          var oldValue = controller.$modelValue;
          if (isDate) {
            angular.forEach(keys, function(key) {
              preserve[key] = controller.$modelValue['get' + key]();
            });
          }
          var value = element.datepicker('getDate');
          controller.$setViewValue(value);

          if (isDate) {
            angular.forEach(keys, function(key) {
               controller.$viewValue['set' + key](preserve[key]);
            });
          }
          if(scope.onDateChanged)
            scope.onDateChanged({ newValue : value, oldValue: oldValue });
        }

        // If we have a controller (i.e. ngModelController) then wire it up
        if (controller) {

          // Set the view value in a $apply block when users selects
          // (calling directive user's function too if provided)
          var _onSelect = opts.onSelect || angular.noop;
          opts.onSelect = function (value, picker) {
            scope.$apply(function() {
              showing = true;
              setVal();
              _onSelect(value, picker);
              element.blur();
            });
          };

          var _beforeShow = opts.beforeShow || angular.noop;
          opts.beforeShow = function(input, picker) {
            showing = true;
            _beforeShow(input, picker);
          };

          var _onClose = opts.onClose || angular.noop;
          opts.onClose = function(value, picker) {
            showing = false;
            _onClose(value, picker);
          };
          element.off('blur.datepicker').on('blur.datepicker', function() {
            if ( !showing ) {
              scope.$apply(function() {
                element.datepicker('setDate', element.datepicker('getDate'));
                setVal();
              });
            }
          });

          // Update the date picker when the model changes
          controller.$render = function () {
            var date = controller.$modelValue;
            if ( angular.isDefined(date) && date !== null && !angular.isDate(date) ) {
                if ( angular.isString(controller.$modelValue) ) {
                    date = uiDateConverter.stringToDate(attrs.uiDateFormat, controller.$modelValue);
                } else {
                    throw new Error('ng-Model value must be a Date, or a String object with a date formatter - currently it is a ' + typeof date + ' - use ui-date-format to convert it from a string');
                }
            }
            element.datepicker('setDate', date);
          };
        }
        
        // Check if the element already has a datepicker.
        if (element.data('datepicker')) {
            // Updates the datepicker options
            element.datepicker('option', opts);
            element.datepicker('refresh');
        } else {
            // Creates the new datepicker widget
            element.datepicker(opts);

            //Cleanup on destroy, prevent memory leaking
            element.on('$destroy', function () {
               element.datepicker('destroy');
            });
        }
        if(scope.minDate){
            setMinDate(scope.minDate);
        }
        if(scope.maxDate){
            setMaxDate(scope.maxDate);
        }
        if ( controller ) {
          // Force a render to override whatever is in the input text box
          controller.$render();
        }
      };
      // Watch for changes to the directives options
      scope.$watch(getOptions, initDateWidget, true);
    }
  };
}
])
.factory('uiDateConverter', ['uiDateFormatConfig', function(uiDateFormatConfig){

    function dateToString(dateFormat, value){
        dateFormat = dateFormat || uiDateFormatConfig;
        if (value) {
            if (dateFormat) {
                return jQuery.datepicker.formatDate(dateFormat, value);
            }

            if (value.toISOString) {
                return value.toISOString();
            }
        }
        return null;
    }

    function stringToDate(dateFormat, value) {
        dateFormat = dateFormat || uiDateFormatConfig;
        if ( angular.isString(value) ) {
            if (dateFormat) {
                return jQuery.datepicker.parseDate(dateFormat, value);
            }

            var isoDate = new Date(value);
            return isNaN(isoDate.getTime()) ? null : isoDate;
        }
        return null;
    }

    return {
        stringToDate: stringToDate,
        dateToString: dateToString
    };

}])
.constant('uiDateFormatConfig', '')
.directive('uiDateFormat', ['uiDateConverter', function(uiDateConverter) {
  var directive = {
    require:'ngModel',
    link: function(scope, element, attrs, modelCtrl) {
        var dateFormat = attrs.uiDateFormat;

        // Use the datepicker with the attribute value as the dateFormat string to convert to and from a string
        modelCtrl.$formatters.unshift(function(value) {
            return uiDateConverter.stringToDate(dateFormat, value);
        });

        modelCtrl.$parsers.push(function(value){
            return uiDateConverter.dateToString(dateFormat, value);
        });

    }
  };

  return directive;
}]);
