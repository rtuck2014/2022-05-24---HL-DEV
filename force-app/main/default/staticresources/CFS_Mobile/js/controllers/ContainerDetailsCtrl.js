define([
  'angular',
  'app',
  'services/historyStorage',
  'services/pageManager',
  'services/jobManager',
  'services/dataProvider',
  'services/cache',
  'services/notifyManager',
  'services/ui/notification'
], function (angular, app) {
  app.controller('ContainerDetailsCtrl', ['$scope', '$rootScope', '$location', '$window', '$route' ,'historyStorage', 'pageManager', 'jobManager', 'dataProvider', 'constants', 'cache', 'notifyManager', 'notification',
    function ($scope, $rootScope, $location, $window, $route, historyStorage, pageManager, jobManager, dataProvider, constants, cache, notifyManager, notification) {
      jobManager.startJob();
      pageManager.setCurrentPage(constants.CONTAINER_DETAILS_PAGE);

      $scope.model = {};
      $window.scrollTo(0, 0);

      var params, search = $location.search();

      if (search) {
        params = {
          id: search.id,
          assignmentId: search.assignmentId,
          top: search.top,
          objectType: search.objectType,
          
          courseAssignmentId : search.courseAssignmentId,
          learningPathAssignmentId : search.learningPathAssignmentId,
          curriculumAssignmentId : search.curriculumAssignmentId
        };
      }

      // by default, we load all data from sfc.
      dataProvider.getContainerDetails(params).then(function (data) {
          
          if (data && data.isCFSUser === false){
              pageManager.goToAccessDeniedPage();
              return;
          }
          
        console.warn('GOOD');
        $scope.model = data;
        $scope.model.parents = [data.parent];

        jobManager.finishJob();
        notification.notify();
        
        console.log(data);
        
        $scope.$emit('showBackToTop');
      }, function (error) {
        console.error('ERROR');
        pageManager.goToErrorPage(error);
      });
    }]);
    
});