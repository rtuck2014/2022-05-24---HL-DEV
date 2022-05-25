define([
    'angular', 
    'app',
    'services/util'
], function (angular, app) {
  app.directive('toggleSearch', ['$interval', 'util', function($interval, util) {
        return {
          restrict: 'CA',
          link: function(scope, element) {
            element.bind(util.clickEvent, function() {
                scope.state.searchVisible = !scope.state.searchVisible;

                if (scope.state.searchVisible === true) {
                  scope.state.currentSearchStr = scope.state.searchStr = '';
                }
                
                scope.$apply();
            });
          }
        };
    }]);
});