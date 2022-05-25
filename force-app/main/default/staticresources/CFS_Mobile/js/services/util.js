define(['angular', 'app'], function (angular, app) {
  app.service('util', ['constants', function (constants) {
    var quizMap = [];
      
    return {
      isContainerType: function (objectType) {
        return objectType === constants.CURRICULUM_TYPE || objectType === constants.LEARNING_PATH_TYPE || objectType === constants.COURSE_TYPE;
      },
      isLowLevelType: function (objectType) {
        return objectType === constants.QUIZ_TYPE || objectType === constants.MODULE_TYPE;
      },
      isModuleCompleted: function (status) {
        return status === constants.COMPLETED_STATUS || status === constants.PASSED_STATUS;
      },
      isIphone: /iphone/i.test(navigator.userAgent.toLowerCase()),
      isIos: /iphone|ipad|ipod/i.test(navigator.userAgent.toLowerCase()),
      clickEvent: document.ontouchstart !== null ? 'click' : 'touchstart',
      hasSessionExpired : function(event) {
        return (event && event.message && event.type == "exception" && event.message.indexOf("Logged in?") != -1);
      }
    }
  }]);
});