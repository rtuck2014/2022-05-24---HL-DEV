define([
  'angular',
  'angularRoute',
  'angularTouch',
  'angularMD5',
  'angularStrap'
], function (angular) {
  return angular.module('cfs', ['ngRoute', 'ngTouch', 'angular-md5', 'mgcrea.ngStrap.alert']);
});