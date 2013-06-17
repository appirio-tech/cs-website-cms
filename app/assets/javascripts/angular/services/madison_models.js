'use strict';

var app = angular.module('madison');

app.factory('Requirement', ['$resource', function($resource) {
    return $resource('/requirements/:id', {id: '@id'}, {update: {method: "PUT"}});
}]);