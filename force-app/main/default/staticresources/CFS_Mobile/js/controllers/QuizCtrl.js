define([
    'angular',
    'app',
    'services/jobManager',
    'services/pageManager'
], function(angular, app) {
    app.controller('QuizCtrl', ['$scope', '$location', '$filter', 'jobManager', 'pageManager', 'dataProvider', 'constants', 
        function($scope, $location, $filter, jobManager, pageManager, dataProvider, constants) {
            jobManager.startJob();
            pageManager.setCurrentPage(constants.QUIZ_PAGE);
            
            var search = $location.search(),
                param = {id: search.id, assignmentId: search.assignmentId},
                saveParam = {quizId: search.id, assignmentId: search.assignmentId},
                submitParam = {assignmentId: search.assignmentId};
            
            $scope.emptyQuestions = [];
            
            $scope.toggleMultiSelect = function(question, answer) {
                var selectedAnswers = question.selectedAnswers,
                    selected = $filter('filter')(selectedAnswers, {id: answer.id})[0],
                    i = selectedAnswers.indexOf(selected);
                
                if(i === -1) {
                    selectedAnswers.push(answer);
                } else {
                    selectedAnswers.splice(i, 1);
                }
                
                $scope.validateQuestions(selectedAnswers, question.id);
                $scope.saveAnswers(question);
            };
            
            $scope.toggleRadio = function(question, answer) {
                angular.forEach(question.answers, function(answ) {
                   answ.checked = false; 
                });
                
                answer.checked = true;
                
                $scope.validateQuestions(question.selectedAnswers, question.id);
                $scope.saveAnswers(question);
            };
            
            $scope.setInitialRadio = function(question) {
                var checkedRadio = $filter('filter')(question.answers, {checked: true})[0];
                
                if(checkedRadio) {
                    question.selectedAnswers[0] = checkedRadio;
                }
            };
            
            $scope.saveAnswers = function(question) {
                if(!$scope.model.maintainUsersAnswers) {
                    return;
                }
                
                var questionClone = JSON.parse(JSON.stringify(question));
                
                saveParam.question = questionClone;
                
                delete saveParam.question.templateUrl;
            
                dataProvider.saveTemporaryQuizAnswers(saveParam).then(function () {
                    console.warn('GOOD');
                }, function (error) {
                    console.error('ERROR');
                    pageManager.goToErrorPage(error);
                });
            };
            
            $scope.validateQuestions = function(selected, id) {
                var i = $scope.emptyQuestions.indexOf(id);
                
                if(selected.length) {
                    if(i > -1) {
                        $scope.emptyQuestions.splice(i, 1);
                    }
                } else {
                    if(i === -1) {
                        $scope.emptyQuestions.push(id);
                    }
                }
            };
            
            $scope.submitQuiz = function() {
                submitParam.quizMetadata = JSON.parse(JSON.stringify($scope.model));
                
                jobManager.startJob();
                
                angular.forEach(submitParam.quizMetadata.questions, function(question) {
                    delete question.templateUrl;    
                });
                
                dataProvider.submitQuiz(submitParam).then(function (data) {
                    jobManager.finishJob();
                    $scope.submittedMessage = data.message;
                    
                    console.warn('GOOD');
                    console.log(data);
                }, function (error) {
                    console.error('ERROR');
                    pageManager.goToErrorPage(error);
                });
            };
            
            /* pagination */
            $scope.currentPage = 0;        
                
            $scope.back = function() {
                $scope.currentPage = $scope.pageBreaks[getPageBreak() - 1] || 0;
                $scope.pageSize = getPageSize() || $scope.pageBreaks[0];        
            };
            
            $scope.next = function() {
                $scope.currentPage = $scope.pageBreaks[getPageBreak() + 1] || $scope.pageBreaks[$scope.currentPage];
                $scope.pageSize = getPageSize() || $scope.model.questions.length - $scope.currentPage;
            };        
            
            $scope.$watch('pageBreaks', function(val) {
                if(val) {
                    $scope.lastPage = $scope.pageBreaks[$scope.pageBreaks.length - 1];
                    $scope.pageSize = $scope.pageBreaks[0];
                }
            });
            
            function getPageBreak() {
                return $scope.pageBreaks.indexOf($scope.currentPage);
            }
            
            function getPageSize() {
                return $scope.pageBreaks[getPageBreak() + 1] - $scope.currentPage;
            }
            
            dataProvider.getQuizLaunchModel(param).then(function (data) {
                
                if (data && data.isCFSUser === false){
                  pageManager.goToAccessDeniedPage();
                  return;
                }
                
                $scope.model = data.quizMetadata;
                $scope.assignmentId = data.assignmentId;
                jobManager.finishJob();
                console.log(data);
              }, function (error) {
                console.error('ERROR');
                pageManager.goToErrorPage(error);
              });
        }]);
});