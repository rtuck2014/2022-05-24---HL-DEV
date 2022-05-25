define([
  'angular',
  'app',
  'services/util'
], function (angular, app) {
  app.factory('itemBuilder', ['$location', 'constants', 'util',
    function ($location, constants, util) {
        
        function encodeQueryData(data)
        {
           var ret = [];
           for (var d in data)
              ret.push(encodeURIComponent(d) + "=" + encodeURIComponent(data[d]));
           return ret.join("&");
        }
        
      return {
        buildUrl: function (item, isTop) {
          if (!constants) {
            alert('$rootScope.CONSTANTS not initialized');
          }

          var containerDetailsRoute = '#/ContainerDetailsMobile',
            moduleDetailsRoute = '#/ModuleDetailsMobile',
            quizDetailsRoute = '#/QuizDetailsMobile';

          var targetRoute = util.isContainerType(item.objectType) ? containerDetailsRoute :
            (item.objectType == constants.MODULE_TYPE) ? moduleDetailsRoute : quizDetailsRoute;
            
          var retUrl = '#' + $location.url();
            
            var queryData = {};
            queryData['id'] = item.id || '';
            queryData['objectType'] = item.objectType || '';
            queryData['assignmentId'] = item.containerAssignmentId || '';
            queryData['top'] = isTop === true;
            queryData['retUrl'] = retUrl;
            queryData['courseAssignmentId'] = item.courseAssignmentId || '';
            queryData['learningPathAssignmentId'] = item.learningPathAssignmentId || '';
            queryData['curriculumAssignmentId'] = item.curriculumAssignmentId || '';
            
          return encodeURI(String.format("{0}?{1}", targetRoute, encodeQueryData(queryData)));
        },
        buildCls: function (item) {
          var containerCls = 'img-container',
            moduleCls = 'img-module',
            quizCls = 'img-quiz';

          if (!item) {
            return;
          }

          return util.isContainerType(item.objectType) ? containerCls :
                (item.objectType == constants.MODULE_TYPE) ? moduleCls : quizCls;
        }
      };
    }]);
});