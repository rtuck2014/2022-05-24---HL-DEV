define(['angular', 'app'], function (angular, app) {
  app.factory('hashcode', ['md5', function (md5) {
    var serialize = function (object) {
      var type = typeof object, serializedCode = "";

      if (type === 'object') {
        var element;

        for (element in object) {
          if (object.hasOwnProperty(element)) {
            serializedCode += "[" + type + ":" + element + serialize(object[element]) + "]";
          }
        }

      } else if (type === 'function') {
        serializedCode += "[" + type + ":" + object.toString() + "]";
      } else {
        serializedCode += "[" + type + ":" + object + "]";
      }

      return serializedCode.replace(/\s/g, "");
    };

    // Public, API
    return function (object) {
      return md5.createHash(serialize(object));
    };
  }]);
});