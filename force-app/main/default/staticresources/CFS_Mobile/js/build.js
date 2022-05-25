require.config({
  urlArgs: "version=" + (new Date()).getTime(),
  waitSeconds: 0,
  paths: {
    angular: 'lib/angular/angular',
    angularRoute: 'lib/angular/angular-route',
    angularTouch: 'lib/angular/angular-touch',
    angularMD5: 'lib/angular/angular-md5',
    angularStrap: 'lib/angular/angular-strap'
  },
  shim: {
    angular: {
      exports: 'angular'
    },
    angularRoute: {
      deps: ['angular']
    },
    angularTouch: {
      deps: ['angular']
    },
    angularMD5: {
      deps: ['angular']
    },
    angularStrap: {
      deps: ['angular']
    }
  }
});

require([
  'angular',
  'main',
  'directives/header',
  'directives/backBtn',
  'directives/toggleSearch',
  'directives/dropdownToggle',
  'directives/launch',
  'directives/enroll',
  'directives/quizElements',
  'directives/modelBlur',
  'filters/filterItems',
  'filters/customOrder',
  'filters/quizPageBreak',
  'filters/trustHtml'
], function (angular) {
    angular.bootstrap(document, ['cfs']);
});