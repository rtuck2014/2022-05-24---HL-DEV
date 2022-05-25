define([
  'angular',
  'app',
  'services/dataLoader',
  'services/cache',
  'services/hashcode'
], function (angular, app) {
  app.factory('dataProvider', ['$rootScope', '$q', 'dataLoader', 'cache', 'hashcode', 'constants', 'util',
    function ($rootScope, $q, dataLoader, cache, hashcode, constants, util) {
        var constantsStateKey = 'constants';
        var myLearningStateKey = 'myLearning';
        var findLearningStateKey = 'findLearning';
        var completedLearningStateKey = 'completedLearning';
    
        var cacheTime = 120000; //120sec.
    
        var getModel = function (stateKey, loaderFnc, loaderFncArguments, useCache) {
          var deffered = $q.defer();
          var model = cache.getData(stateKey);
    
          if (useCache === false || !model || !model.timestamp || (model.timestamp + cacheTime <= new Date().getTime())) {
            console.warn('load data from server');
            loaderFnc(loaderFncArguments).then(function (data) {
                if (data){
                  model = data;
                  model.timestamp = new Date().getTime();
                  cache.saveData(stateKey, model);
                  deffered.resolve(model);     
                } else {
                  deffered.resolve();
                }
              
            }, function (error) {
                if (util.hasSessionExpired(error)){
                    window.location.reload();
                    return;
                }
              deffered.reject(error);
            });
          } else {
            console.info('load data from cache');
            deffered.resolve(model);
          }
    
          return deffered.promise;
        };
    
        var defaultParam = {
          orderBy: constants.ORDER_BY_TITLE,
          ascending: false,
          searchStr: ''
        };
    
        /* build data provider return object */
        var dataProviderBase = {
            getMyLearning: function (param) {
                console.log('getMyLearning called');
                if (!param) {
                    param = defaultParam;
                }
        
                param.reqId = myLearningStateKey;
                
                return getModel(hashcode(param), dataLoader.getMyLearning.fn, param);
            },
            getFindLearning: function (param) {
                console.log('getFindLearning called');
                if (!param) {
                    param = defaultParam;
                }
                
                param.reqId = findLearningStateKey;
                
                return getModel(hashcode(param), dataLoader.getFindLearning.fn, param);
            },
            getCompletedLearning: function (param) {
                console.log('getCompletedLearning called');
                if (!param) {
                    param = defaultParam;
                }
                
                param.reqId = completedLearningStateKey;
                
                return getModel(hashcode(param), dataLoader.getCompletedLearning.fn, param);
            }
        }, dataProvider = {};
        
        angular.forEach(dataLoader, function(loader, key) {
            dataProvider[key] = function(param) {
                var hashParam = loader.stateKey === false ? loader.stateKey : hashcode(param),
                    useCache = loader.useCache !== false;
                
                console.log(key + ' called');
                
                if (!param) {
                  alert('param is empty!');
                  return;
                }
                
                return getModel(hashParam, loader.fn, param, useCache);
            };
        });
    
        angular.extend(dataProvider, dataProviderBase);
        /* end build data provider return object */
        
        return dataProvider;
    }]);
});