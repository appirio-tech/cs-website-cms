'use strict';

var app = angular.module('madison');

app.factory('Requirement', ['$resource', function($resource) {
    // see requirements controller
    return $resource('/requirements/:id', {id: '@id'}, {update: {method: "PUT"}});
}]);