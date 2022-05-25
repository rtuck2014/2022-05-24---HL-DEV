define(['angular', 'app'], function (angular, app) {
  app.factory('notifyManager', function(){
    var notifications = [];

    return {
      add: function(message) {
        notifications.push(message);
      },    
      get: function() {
        return notifications.pop(); 
      },
      isEmpty: function() {
        return notifications.length === 0;
      }
    };
  });
});