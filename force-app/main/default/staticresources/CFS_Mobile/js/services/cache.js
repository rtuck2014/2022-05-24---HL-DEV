define(['angular', 'app'], function (angular, app) {
  app.factory('cache', ['$cacheFactory', function($cacheFactory) {
    var appCache = $cacheFactory('dataCache', {capacity : 15});

    return {
      saveData : function(key, data){
        appCache.put(key, data);
      },
      getData : function(key){
        return appCache.get(key);
      },
      reset : function(){
          appCache.removeAll();
      }
    };
  }]);
});