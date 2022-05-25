define([
    'angular',
    'app',
    'services/jobManager',
    'services/dataProvider',
    'services/cache',
    'services/notifyManager',
    'services/pageManager'
], function(angular, app) {
    app.directive('enroll', ['$location', 'jobManager', 'dataProvider', 'cache', 'notifyManager', 'labels', 'constants', 'pageManager', 'util',
        function($location, jobManager, dataProvider, cache, notifyManager, labels, constants, pageManager, util) {
            return {
                restrict: 'EA',
                templateUrl: 'enroll',
                replace: true,
                scope: {
                    enrollModel: '=',
                    model: '='
                },
                link: function (scope, element, attrs) {
                  element.bind(util.clickEvent, function() {
                    jobManager.startJob();
                    scope.$apply();
                  
                    var param = {id: attrs.id, objectType: attrs.type};
                    
                    dataProvider.doEnroll(param).then(function (data) {
                        jobManager.finishJob();
                    
                        if (data.success) {
                          var currentParam = $location.search();
                          
                          currentParam.assignmentId = data.item.containerAssignmentId;
                          currentParam.courseAssignmentId = data.item.courseAssignmentId;
                          currentParam.learningPathAssignmentId = data.item.learningPathAssignmentId;
                          currentParam.curriculumAssignmentId = data.item.curriculumAssignmentId;
                    
                          cache.reset();
                          notifyManager.add({content: labels.getLabel(constants.SHOW_MESSAGE)});
                          
                          $location.search(currentParam);
                          $location.replace();
                        }
                        console.log(data);
                    
                      }, function (error) {
                        console.error('ERROR');
                        pageManager.goToErrorPage(error);
                      });
                  });
                }
            };
        }]);
    });