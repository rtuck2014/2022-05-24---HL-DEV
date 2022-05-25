define([
  'angular',
  'app',
  'services/historyStorage',
  'services/pageManager',
  'services/jobManager',
  'services/util'
], function (angular, app) {
  app.controller('AppCtrl', ['$scope', '$location', '$anchorScroll', '$timeout', 'historyStorage', 'pageManager', 'jobManager', 'constants', 'util',
    function ($scope, $location, $anchorScroll, $timeout, historyStorage, pageManager, jobManager, constants, util) {
      jobManager.startJob();

      // functions.
      $scope.getOrderByField = function (orderBy) {
        if (constants.ORDER_BY_TITLE_ASCENDING == orderBy || constants.ORDER_BY_TITLE_DESCENDING == orderBy) {
          return constants.ORDER_BY_TITLE;
        }
        return orderBy;
      };

      $scope.getOrderDuration = function (orderBy, ascending) {
        if (constants.ORDER_BY_TITLE_ASCENDING == orderBy) {
          return false;
        }

        if (constants.ORDER_BY_TITLE_DESCENDING == orderBy) {
          return true;
        }

        return ascending;
      };

      $scope.filter = function ($event) {
        var el = $event.target,
          data = el.dataset;

        $scope.state.orderBy = data.orderBy;
        $scope.state.ascending = data.ascending;
        $scope.currentSortStr = el.innerHTML;
      };

      $scope.submitSearch = function () {
        $scope.state.searchStr = $scope.state.currentSearchStr;
        
        $scope.$emit('showBackToTop');
      };

      // watch.
      $scope.$watch(function () {
        return pageManager.getCurrentPage();
      }, function () {
        console.log('current page changed!!!');
        $scope.currentPage = pageManager.getCurrentPage();
      });

      // on update state, save to history.
      $scope.$watch('state', function () {
        if ($scope.state) {
          console.log('state saved to history');
          $scope.currentSortStr = $scope.labels.getLabel($scope.state.orderBy);
          historyStorage.putState($scope.state);
        }
      }, true);

      $scope.$watch(function () {
        return jobManager.isBusy();
      }, function () {
        $scope.isBusy = jobManager.isBusy();
      });
      
      $scope.showScrollToTop = false;
      
      $scope.$on('showBackToTop', function() {
          $scope.showScrollToTop = false;
          
          $timeout(function() {
            $scope.showScrollToTop = window.scrollY > 0 || ((document.querySelector('.ng-view').clientHeight + 60 > window.screen.availHeight) && util.isIos);
          }, 1000);
      });
          
      angular.element(window).on('scroll', function() {
        var currentValue = window.scrollY > 0;
        
        if ($scope.showScrollToTop !== currentValue){
            $scope.showScrollToTop = currentValue;
            $scope.$apply();
        } 
      });
      
      $scope.goToTop = function(hash) {
        if(util.isIos) {
            $location.hash(hash);
            $anchorScroll();    
        } else {
            window.scrollTo(0,0);
        }
      };
      
      jobManager.finishJob();
    }]);
});