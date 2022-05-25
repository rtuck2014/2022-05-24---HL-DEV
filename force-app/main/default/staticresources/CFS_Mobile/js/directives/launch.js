define([
    'angular',
    'app',
    'services/dataProvider',
    'services/util',
    'services/pageManager',
    'services/cache',
    'services/jobManager'
], function (angular, app) {
    app.directive('launch', ['$interval', 'dataProvider', 'util', 'pageManager', 'cache', 'jobManager',
        function($interval, dataProvider, util, pageManager, cache, jobManager) {
            var fakeLink = angular.element('<a href=""></a>'),
                link = function(scope, element, attrs) {
                    element.find('button').bind(util.clickEvent, function() {
                        if(attrs.quizPage) {
                            pageManager.goToPage(attrs.quizPage);
                            scope.$apply();
                        } else {
                            var param = {assignmentId: scope.model.item.containerAssignmentId};
    
                            scope.isLoading = true;
                            jobManager.startJob();
                            scope.$apply();
    
                            dataProvider.getLaunch(param).then(function (data) {
                                cache.reset();
                                jobManager.finishJob();
                                fakeLink.attr('href', data.launchLink);
    
                                var evt = document.createEvent('MouseEvent');
                                evt.initEvent('click', false, true);
                                fakeLink[0].dispatchEvent(evt);
                                
                                var stop = $interval(function () {
                                    scope.needRefresh = true;
                                    $interval.cancel(stop);
                                }, 2000);
                                
                            }, function (error) {
                                console.error('ERROR');
                                pageManager.goToErrorPage(error);
                            });
                        }
                    });
                };

            return {
                restrict: 'CE',
                replace: true,
                templateUrl: 'launch',
                compile: function(tElem) {
                    tElem.append(fakeLink);

                    return link;
                }
            };
        }]);
});