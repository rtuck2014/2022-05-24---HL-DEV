define([
    'angular',
    'app',
    'services/util'
], function(angular, app) {
    app.directive('quizElements', ['$compile', 'constants', 'util', function($compile, constants, util) {
        return {
            restrict: 'CA',
            link: function(scope, elem, attrs) {
                
                scope.$watch('model', function(model) {
                    if(model) {
                        scope.pageBreaks = [];
                        
                        angular.forEach(model.questions, function(question, key) {
                            var type = question.questionType || constants.QUESTION_NO_TYPE,
                                templateUrl = type.replace(/[\/\s]+/, '-').toLowerCase();
                                
                            if(type === constants.QUESTION_TYPE_FREE_TEXT) {
                                templateUrl += '-' + question.multiLine;
                            }
                            
                            if(type === constants.QUESTION_TYPE_PAGE_BREAK) {
                                scope.pageBreaks.push(key);
                            }
                  
                            question.templateUrl = templateUrl;
                            
                            console.log(question);
                        });
                    }
                });
            }
        };
    }]);
});