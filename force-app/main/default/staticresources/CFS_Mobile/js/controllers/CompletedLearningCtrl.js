define([
  'angular',
  'app',
  'services/historyStorage',
  'services/pageManager',
  'services/jobManager',
  'services/dataProvider'
], function (angular, app) {
  app.controller('CompletedLearningCtrl', ['$scope', 'historyStorage', 'pageManager', 'jobManager', 'dataProvider', 'constants',
    function ($scope, historyStorage, pageManager, jobManager, dataProvider, constants) {
      jobManager.startJob();
      pageManager.setCurrentPage(constants.COMPLETED_LEARNING_PAGE);

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
          searchVisible: true
        };
      }

      dataProvider.getCompletedLearning().then(function (data) {
          
          if (data && data.isCFSUser === false){
              pageManager.goToAccessDeniedPage();
              return;
          }
          
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