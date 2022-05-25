define([
    'angular', 
    'app',
    'services/notifyManager'
], function(angular, app) {
    app.factory('notification', ['$location', '$alert', 'constants', 'notifyManager',
        function($location, $alert, constants, notifyManager) {
            return {
                notify: function() {
                    if(notifyManager.isEmpty()) {
                        return;
                    }
                    
                    var defaults = {type: 'success', duration: 1, placement: 'top', show: true, template: 'alert.tpl'},
                        config = angular.extend(defaults, notifyManager.get());
                    
                    $alert(config);
                }
            };    
        }]);
});