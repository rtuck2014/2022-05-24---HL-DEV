define(['angular', 'app'], function (angular, app) {
  app.directive('appHeader', function(){
    return {
      restrict: 'EA',
      templateUrl: 'app-header'
    }
  });
});