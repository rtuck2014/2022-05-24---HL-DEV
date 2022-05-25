define([
    'angular', 
    'app',
    'services/util'
], function (angular, app) {
  app.directive('backBtn', ['$location', 'util', function($location, util) {
    return {
      restrict: 'EA',
      templateUrl: 'back-btn',
      scope: {
          backText: '@'
      },
      replace: true,
      link: function(scope, element, attrs) {
        if(util.isIos) {
            scope.$on('$routeChangeSuccess', function () {
                var retUrl = $location.search().retUrl;
                
                if(retUrl) {
                    scope.backUrl = decodeURIComponent($location.search().retUrl);
                }
            });
            
            return; 
        }          
          
        element.bind(util.clickEvent, goBack);

        function goBack() {
          history.go(-1);
        }
      }
    }
  }]);
});