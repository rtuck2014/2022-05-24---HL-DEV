define(['angular', 'app'], function(angular, app) {
    app.filter('trustHtml', ['$sce', function($sce) {
        return function(input) {
            return $sce.trustAsHtml(input);
        };
    }]);
});