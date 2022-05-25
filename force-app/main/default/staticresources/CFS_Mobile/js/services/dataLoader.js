define(['angular', 'app'], function (angular, app) {
  app.factory('dataLoader', ['$q', function ($q) {
    var dataLoader = {};
    
    /* build data loader return object */
    angular.forEach(apiPath, function(api, key) {
        var dataLoaderObj = dataLoader[key] = {};
        
        dataLoaderObj.useCache = api.useCache !== false;
        dataLoaderObj.stateKey = api.stateKey;
        
        dataLoaderObj.fn = function(param) {
            var deffered = $q.defer(),
                callback = function (result, event) {
                    if (event.status) {
                        deffered.resolve(result);
                        console.log(key + ' - ok!');
                    } else {
                        console.error(key + ' - error!');
                        console.error(event);
                        deffered.reject(event);
                    }
                };
            
            if(api.noParam) {
                param = callback;
                callback = undefined;
            }
            
            Visualforce.remoting.Manager.invokeAction(api.url, param, callback, {timeout: 120000});
            
            return deffered.promise;
        };
    });
    /* end build data loader return object */
    
    return dataLoader;
  }]);
});