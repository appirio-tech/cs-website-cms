'use strict';

var app = angular.module('madison');

app.controller('MainUICtrl', ['$scope', '$routeParams', 'Requirement', function($scope, $routeParams, Requirement) {

  $scope.requirements = Requirement.query({challenge_id: $routeParams.challenge_id});
  $scope.requirement = null;
  $scope.mode = 'add';

  $scope.types = ["Yes/No","1-4","1-5","1-10","Comments"];  

  $scope.libraries = [
    {name: "Salesforce.com", value: "Salesforce.com"},
    {name: "Generic", value: "All"}
  ];  

  $scope.addFromLibrary = function() {
    Requirement.query({library: $scope.library.value}, function(requirements) {
        angular.forEach(requirements, function(req){
          var converted = convertRequirement(req);
          $scope.requirements.push(converted);
          converted.$save();
        });     
    });
    // if they picked something besides Generic / All, load all generic also
    if ($scope.library.value != 'All') {
      Requirement.query({library: 'All'}, function(requirements) {
          angular.forEach(requirements, function(req){
            var converted = convertRequirement(req);
            $scope.requirements.push(converted);
            converted.$save();
          });     
      });    
    }
  }

  $scope.add = function() {
    var requirement = newRequirement($scope.newRequirement.description);
    requirement.$save(function() {
      $scope.requirements.push(requirement);
      $scope.newRequirement = null;
    });
  }  

  $scope.edit = function(requirement) {
    $scope.mode = 'edit';
    $scope.requirement = requirement;
  }  

  $scope.delete = function(requirement) {
    var index = $scope.requirements.indexOf(requirement);
    $scope.requirements.splice(index,1);
    requirement.$delete();    
  }    

  $scope.save = function() {
    $scope.requirement.$update();
    $scope.requirement = null;
    $scope.mode = 'add';
  }    

  $scope.cancel = function() {
    $scope.requirement = null;
    $scope.mode = 'add';
  }      

  function newRequirement(description) {
    var r = new Requirement();
    r.description = description;
    r.section = 'Functional';
    r.scoring_type = '1-4';
    r.challenge_id = $routeParams.challenge_id;
    r.active = true;
    r.weight = .1
    r.order_by = $scope.requirements.length+1
    return r;
  }

  function convertRequirement(requirement) {
    requirement.id = null;
    requirement.challenge_id = $routeParams.challenge_id;
    requirement.library = null;
    requirement.order_by = $scope.requirements.length+1
    return requirement;
  }

}]);