define(['angular', 'app'], function(angular, app) {
    app.config(function($routeProvider) {
        console.log('app config');
        $routeProvider.when('/', {
            templateUrl: 'learning',
            controller: 'MyLearningCtrl'
        })
        
        .when('/FindLearning', {
            templateUrl: 'learning',
            controller: 'FindLearningCtrl'
        })
        .when('/CompletedLearning', {
            templateUrl: 'learning',
            controller: 'CompletedLearningCtrl'
        })
        
        .when('/ContainerDetailsMobile', {
            templateUrl: 'containerDetails',
            controller: 'ContainerDetailsCtrl'
        })
        .when('/ModuleDetailsMobile', {
            templateUrl: 'details',
            controller: 'ModuleDetailsCtrl'
        })
        
        .when('/QuizDetailsMobile', {
            templateUrl: 'details',
            controller: 'ModuleDetailsCtrl'
        })
        .when('/QuizMobile', {
            templateUrl: 'quiz',
            controller: 'QuizCtrl'
        })
        
        .when('/error', {
            templateUrl: 'error',
            controller: 'ErrorCtrl'
        })
        .otherwise({
            redirectTo: '/'
        });
    });
});