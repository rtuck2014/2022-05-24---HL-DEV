define(['angular', 'app'], function (angular, app) {
  app.filter('customOrder', ['constants', function (constants) {
    var numberComparator = function (valueA, valueB) {
      if (!valueA && !valueB) {
        return 0;
      }

      if (!valueA) {
        return 1;
      }

      if (!valueB) {
        return -1;
      }

      return valueA - valueB;
    };

    var comparators = {};

    comparators[constants.ORDER_BY_TYPE] = function (a, b) {
      return numberComparator(a[constants.ORDER_BY_TYPE], b[constants.ORDER_BY_TYPE]);
    };

    comparators[constants.ORDER_BY_STATUS] = function (a, b) {
      return numberComparator(a[constants.ORDER_BY_STATUS], b[constants.ORDER_BY_STATUS]);
    };

    comparators[constants.ORDER_BY_DUE_DATE] = function (a, b) {
      return numberComparator(a[constants.ORDER_BY_DUE_DATE], b[constants.ORDER_BY_DUE_DATE]);
    };

    comparators[constants.ORDER_BY_DURATION] = function (a, b) {
      return numberComparator(a[constants.ORDER_BY_DURATION], b[constants.ORDER_BY_DURATION]);
    };

    comparators[constants.ORDER_BY_COMPLETION] = function (a, b) {
      return numberComparator(a[constants.ORDER_BY_COMPLETION], b[constants.ORDER_BY_COMPLETION]);
    };

    comparators[constants.ORDER_BY_SEQUENCE] = function (a, b) {
      return numberComparator(a[constants.ORDER_BY_SEQUENCE], b[constants.ORDER_BY_SEQUENCE]);
    };

    comparators[constants.ORDER_BY_TITLE] = function (a, b) {

      var valueA = a[constants.ORDER_BY_TITLE],
        valueB = b[constants.ORDER_BY_TITLE];

      if (!valueA && !valueB) {
        return 0;
      }

      if (!valueA) {
        return -1;
      }

      if (!valueB) {
        return 1;
      }

      return valueA.localeCompare(valueB);
    };

    comparators[constants.ORDER_BY_TITLE_ASCENDING] = comparators[constants.ORDER_BY_TITLE_DESCENDING] = comparators[constants.ORDER_BY_TITLE];

    var getComparator = function (orderBy) {
      return comparators[orderBy];
    };

    return function (items, orderBy, ascending) {

      if (!items) {
        return;
      }

      if (!orderBy) {
        return items;
      }

      var itemsClone = items.slice(0),
        comparator = getComparator(orderBy);

      itemsClone.sort(comparator);

      if (ascending == 'false') {
        itemsClone.reverse();
      }

      return itemsClone;
    };
  }]);
});