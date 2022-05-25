define(['angular', 'app'], function (angular, app) {
  app.factory('labels', ['constants', function (constants) {
    var labels = {};

    // pages.
    labels[constants.MY_LEARNING_PAGE] = 'My Learning';
    labels[constants.FIND_LEARNING_PAGE] = 'Find Learning';
    labels[constants.COMPLETED_LEARNING_PAGE] = 'Completed';

    // order.
    labels[constants.ORDER_BY_TITLE_ASCENDING] = 'Sort by Title (A-Z)';
    labels[constants.ORDER_BY_TITLE_DESCENDING] = 'Sort by Title (Z-A)';
    labels[constants.ORDER_BY_TYPE] = 'Sort by Type';
    labels[constants.ORDER_BY_STATUS] = 'Sort by Status';
    labels[constants.ORDER_BY_DUE_DATE] = 'Sort by Due Date';
    labels[constants.ORDER_BY_DURATION] = 'Sort by Duration';
    labels[constants.ORDER_BY_SEQUENCE] = 'Sort by Sequence';
    labels[constants.ORDER_BY_COMPLETION] = 'Sort by Completition';
    
    labels[constants.ACCESS_DENIED] = 'You are not authorized for this activity. Please contact support for authorization.';
    

    // misc
    labels[constants.SHOW_MESSAGE] = 'The enrollment was successful';

    return {
      getLabel: function (key) {
        if (!key) {
          return;
        }
        if (key in labels) {
          return labels[key];
        }
        console.warn('label not found! key = ' + key);
      }
    };
  }]);
});