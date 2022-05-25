define([
  'angular',
  'app',
  'services/pageManager',
  'services/jobManager',
  'services/dataProvider',
  'services/ui/notification'
], function (angular, app) {
  app.controller('ModuleDetailsCtrl', ['$scope', '$location', '$window', '$route', '$interval', 'pageManager', 'jobManager', 'dataProvider', 'constants', 'notification',
    function ($scope, $location, $window, $route, $interval, pageManager, jobManager, dataProvider, constants, notification) {
        
      $scope.refresh = function () {
          jobManager.startJob();
          $interval(function(){
                $route.reload();      
                jobManager.finishJob();
          }, 3000, 1, true);
      };

      jobManager.startJob();
      pageManager.setCurrentPage(constants.MODULE_DETAILS_PAGE);

      $scope.model = {};
      $window.scrollTo(0, 0);
      $scope.needRefresh = false;

      var params;

      if ($location.search()) {
        params = {
          id: $location.search().id,
          assignmentId: $location.search().assignmentId,
          top: $location.search().top,
          objectType: $location.search().objectType
        };
      }

      dataProvider.getModuleDetails(params).then(function (data) {
          
          if (data && data.isCFSUser === false){
              pageManager.goToAccessDeniedPage();
              return;
          }
          
        console.warn('GOOD');
        $scope.model = data;
        $scope.model.items = [data.item];

        jobManager.finishJob();
        notification.notify();
        
        console.log(data);
        
        $scope.$emit('showBackToTop');
      }, function (error) {
        console.log('ERROR');
        pageManager.goToErrorPage(error);
      });

      $scope.$watch('needRefresh', function (newValue) {
        if ($scope.model.items && $scope.model.items.length) {
          $scope.model.items[0].needRefresh = newValue;
        }
      });
    }]);
});