define([
  'angular',
  'app',
  'services/historyStorage',
  'services/pageManager',
  'services/jobManager',
  'services/dataProvider'
], function (angular, app) {
  app.controller('FindLearningCtrl', ['$scope', '$rootScope', '$location', 'historyStorage', 'pageManager', 'jobManager', 'dataProvider', 'constants',
    function ($scope, $rootScope, $location, historyStorage, pageManager, jobManager, dataProvider, constants) {
      jobManager.startJob();
      pageManager.setCurrentPage(constants.FIND_LEARNING_PAGE);

      $scope.model = {};

      var cachedState = historyStorage.getState();

      if (cachedState && cachedState.orderBy) {
        $scope.$parent.state = cachedState;
      } else {
        // default state.
        $scope.$parent.state = {
          searchStr: '',
          currentSearchStr: '',
          orderBy: constants.ORDER_BY_TITLE_ASCENDING,
          ascending: true,
          searchVisible: false
        };
      }

      if ($location.search().q) {
        $scope.$parent.state.searchStr = $scope.$parent.state.currentSearchStr = $location.search().q;
        $scope.$parent.state.searchVisible = false;
      }

      dataProvider.getFindLearning().then(function (data) {
          
          if (data && data.isCFSUser === false){
              pageManager.goToAccessDeniedPage();
              return;
          }
          
        console.warn('GOOD');
        $scope.model.items = data.items;
        jobManager.finishJob();
        console.log(data);
        
        $scope.$emit('showBackToTop');
      }, function (error) {
        console.error('ERROR');
        pageManager.goToErrorPage(error);
      });
    }]);
});