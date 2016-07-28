/*global angular module*/
/*annotationService.js*/

angular.module('app').factory('annotation', ['$http', '$q', function($http, $q) {

	var annotate = function(anno, isDelete) {
		// copy anno except for highlights attr;
		var anno_copy = {};
		for (var key in anno) {
			if (key === 'highlights') {
				continue;
			}
			anno_copy[key] = anno[key];
		}

		var index = 'annotator.offline/annotation.' + anno_copy.id;
		return $q(function(reslove, reject) {
			isDelete ? localStorage.removeItem(index) : localStorage.setItem(index, angular.toJson(anno_copy));

			reslove();
		});
	};

	return {
		annotate: annotate
	};

}]);