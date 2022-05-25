define(['angular', 'app'], function(angular, app) {
    app.directive('modelBlur', function() {
        return {
            require: 'ngModel',
            priority: 1,
            link: function(scope, elem, attrs, ngModelCtrl) {
                if (attrs.type === 'radio' || attrs.type === 'checkbox') return;
    
                elem.unbind('input').unbind('keydown').unbind('change');
                elem.bind('blur', function() {
                    scope.$apply(function() {
                        ngModelCtrl.$setViewValue(elem.val());
                    });        
                    scope.$apply(attrs.modelBlur);
                });
            }
        };
    });    
});