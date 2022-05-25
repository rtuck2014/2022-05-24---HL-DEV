define(['angular', 'app'], function (angular, app) {
    app.filter('quizStartFrom', function() {
        return function(input, start) {
            if(!input) {
                return;
            }
            
            start = +start;        
            return input.slice(start);
        }
    });
});