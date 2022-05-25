define(['angular', 'app'], function (angular, app) {
  app.factory('jobManager', function(){
    var totalAvtiveJobs = 0;

    return {
      startJob : function(){
        totalAvtiveJobs++;
      },

      finishJob : function(){
        if (totalAvtiveJobs > 0) totalAvtiveJobs--;
      },

      isBusy : function(){
        return totalAvtiveJobs !== 0;
      },

      reset : function(){
        totalAvtiveJobs = 0;
      }

    };
  });
});