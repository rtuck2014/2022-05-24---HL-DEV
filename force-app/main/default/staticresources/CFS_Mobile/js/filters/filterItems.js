define(['angular', 'app'], function (angular, app) {
  app.filter('filterItems', function (filterFilter) {
    return function (items, searchStr) {
      if (!items) {
        return;
      }

      if (!searchStr) {
        return items;
      }
      
      searchStr = String(searchStr)
            .replace(/&/g, '&amp;')
            .replace(/"/g, '&quot;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;');
        
      var arrayToReturn = [];
      for (var i = 0; i < items.length; i++) {
        if (items[i].title && items[i].title.toUpperCase().indexOf(searchStr.toUpperCase()) !== -1) {
          arrayToReturn.push(items[i]);
        }
      }

      return arrayToReturn;
      
    };
  });
});