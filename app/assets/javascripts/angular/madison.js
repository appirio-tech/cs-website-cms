'use strict';
/*
    This is our main launch point from Angular. We'll put anything to do with the
    general well being of our app in this file. For now it'll basically just contain
    the routing information.

    Our module will be called 'app'.
 */
angular.module('madison', ['ngResource', 'ui.sortable', 'ui.slider'])
  .config(['$routeProvider', '$locationProvider', function($routeProvider, $locationProvider) {
    $routeProvider
      .when(
        '/:challenge_id', {controller: 'MainUICtrl', 
        templateUrl: '/assets/angular/templates/madison_index.html'
      })
      .otherwise({redirectTo: '/'});
}]);