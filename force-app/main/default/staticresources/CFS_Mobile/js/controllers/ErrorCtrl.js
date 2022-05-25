define([
  'angular',
  'app',
  'services/pageManager'
], function (angular, app) {
  app.controller('ErrorCtrl', ['$scope', '$location', 'pageManager', 'constants',
    function ($scope, $location, pageManager, constants) {
      var errorObjectMessage;

      pageManager.setCurrentPage(constants.ERROR_PAGE);

      if ($location.search().errorMessage) {
          
          if ($location.search().jsonMessage){
                errorObjectMessage = JSON.parse($location.search().errorMessage);      
          } else{
                errorObjectMessage = $location.search().errorMessage;      
          }
        
      } else {
        errorObjectMessage = {
          message: 'Unknown error'
        };
      }

      $scope.errorMessage = errorObjectMessage.message ? errorObjectMessage.message : errorObjectMessage;
      $scope.pageToRefresh = $location.search().pageToRefresh;

      if ($location.search().urlParams) {
        $scope.urlParams = JSON.parse($location.search().urlParams);
      } else {
        $scope.urlParams = {};
      }
        
        /*
      $scope.refresh = function () {
        pageManager.goToPage($scope.pageToRefresh, $scope.urlParams, true);
      }
      */
    }]);
});