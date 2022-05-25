define([
  'angular',
  'app',
  'controllers/AppCtrl',
  'controllers/MyLearningCtrl',
  'controllers/FindLearningCtrl',
  'controllers/CompletedLearningCtrl',
  'controllers/ContainerDetailsCtrl',
  'controllers/ModuleDetailsCtrl',
  'controllers/QuizCtrl',
  'controllers/ErrorCtrl',
  'services/pageManager',
  'services/jobManager',
  'services/itemBuilder',
  'services/util',
  'services/labels',
  'misc/config',
  'misc/constant'
], function (angular, app) {
  app.run(function($rootScope, pageManager, jobManager, itemBuilder, constants, util, labels){
    console.log('app run');
    $rootScope.itemBuilder = itemBuilder;
    $rootScope.pageManager = pageManager;
    $rootScope.CONSTANTS = constants;
    $rootScope.labels = labels;
    $rootScope.util = util;

    $rootScope.$on("$routeChangeStart", function() {
      jobManager.reset();
    });
  });
});