define(['angular', 'app'], function (angular, app) {
  app.factory('pageManager', ['$location', 'constants', 'labels', function ($location, constants, labels) {
    var managerData = {};

    return {
      getCurrentPage: function () {
        return managerData.currentPage;
      },
      setCurrentPage: function (pageName) {
        managerData.currentPage = pageName;
      },
      isTopPage: function (pageName) {
        return pageName == constants.MY_LEARNING_PAGE || pageName == constants.FIND_LEARNING_PAGE || pageName == constants.COMPLETED_LEARNING_PAGE;
      },
      goToPage: function (path, searchParams, withoutHistory) {
        path = path || '/';

        if (searchParams) {
          $location.path(path).search(searchParams);
        } else {
            console.log(path);
          $location.path(path);
        }

        if (withoutHistory === true) {
          $location.replace();
        }
      },
      goToErrorPage: function (error) {
        var urlParams = {
          errorMessage: JSON.stringify(error),
          pageToRefresh: $location.path(),
          jsonMessage: true,
          'urlParams': JSON.stringify($location.search())
        };
        this.goToPage('/error', urlParams, true);
      },
      goToAccessDeniedPage: function(){
         var urlParams = {
            errorMessage: labels.getLabel(constants.ACCESS_DENIED),
            pageToRefresh: $location.path(),
            'urlParams': JSON.stringify($location.search())
        };
        this.goToPage('/error', urlParams, true);
      },
      isScrolablePage: function(){
        var currentPage = this.getCurrentPage();     
        return this.isTopPage(currentPage) || currentPage == constants.CONTAINER_DETAILS_PAGE;
      }
    };
  }]);
});