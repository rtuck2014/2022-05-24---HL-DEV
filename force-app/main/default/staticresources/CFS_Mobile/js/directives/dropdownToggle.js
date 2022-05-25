define([
    'angular', 
    'app',
    'services/util'
], function (angular, app) {
  app.directive('dropdownToggle', ['$document', '$location', 'util', function ($document, $location, util) {
    var openElement = null,
      closeMenu = angular.noop;

    return {
      restrict: 'CA',
      link: function (scope, element, attrs) {
        scope.$watch('$location.path', function () {
          closeMenu();
        });
        element.parent().bind(util.clickEvent, function () {
          closeMenu();
        });

        element.bind(util.clickEvent, function (event) {
          var elementWasOpen = (element === openElement);

          event.preventDefault();
          event.stopPropagation();

          if (!!openElement) {
            closeMenu();
          }

          if (!elementWasOpen && !element.hasClass('disabled') && !element.prop('disabled')) {
            element.parent().addClass('opened');
            openElement = element;
            closeMenu = function (event) {
              if (event) {
                event.preventDefault();
                event.stopPropagation();
              }

              $document.unbind(util.clickEvent, closeMenu);
              element.parent().removeClass('opened');
              closeMenu = angular.noop;
              openElement = null;
            };

            $document.bind(util.clickEvent, closeMenu);
          }
        });
      }
    };
  }]);
});