define(['angular', 'app'], function (angular, app) {
  app.factory('historyStorage', ['$location', function($location) {
    return {
      putState: function(state) {
          history.replaceState(state, '', $location.absUrl());
        },
        getState: function() {
          return window.history.state;
        }
    };
  }]);
});