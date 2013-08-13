'use strict';

var app = angular.module('madison');

var SLIDER_STEP = 5;
app.controller('MainUICtrl', ['$scope', '$routeParams', 'Requirement', function($scope, $routeParams, Requirement) {

  $scope.requirements = Requirement.query({challenge_id: $routeParams.challenge_id});
  $scope.requirement = null;
  $scope.mode = 'add';

  $scope.types = ["Yes/No","1-4","1-5","1-10","Comments"];  

  $scope.libraries = [
    {name: "Salesforce.com", value: "Salesforce.com"},
    {name: "Generic", value: "All"}
  ];  

  // determine which section will be shown on Weight tab.
  $scope.showWeightSection = function(section) {
    // shows sections if use_advanced_features is checked.
    if($scope.use_advanced_features && section !== "all")
      return true;

    // shows section named 'all', which contains all questions, if use_advanced_features is not checked.
    if(!$scope.use_advanced_features && section === "all")
      return true;

    return false;
  };

  // In order to use Weight tab pannel view, 
  // prepare reqsBySection(requirements grouped By Section) model, 
  // section is the one used when 'use_advanced_features' is on.
  // section named 'all' is the special one, which contains all questions, and is used 
  // when 'use_advanced_features' is off.
  $scope.prepareForWeight = function() {
    var reqsBySection = {};

    reqsBySection["all"] = [];
    angular.forEach($scope.requirements, function(req) {
      reqsBySection[req.section] = reqsBySection[req.section] || [];

      reqsBySection[req.section].push({
        id: req.id,
        description: req.description,
        weight: req.weight * 100,
        isLocked: false
      });

      reqsBySection["all"].push({
        id: req.id,
        description: req.description,
        weight: req.weight * 100,
        isLocked: false
      })
    });

    $scope.reqsBySection = reqsBySection;

    for(var section in reqsBySection) {
      // adjust weights just to make sure the total weights of the group is 100
      adjustWeight(section, reqsBySection[section][0]);
    }
  };

  // adjusts weights of questions in the group so that make sure the total of weights are 100.
  // 1. calculate overflow/underflow numbers of weights.
  // 2. And also gather target questions to decrease/increase weight.
  // 3. In case of overflow, decrease the weights of target.
  // 4. In case of underflow, increase the weights of target.
  // 5. So as a result, the total number of weight goes 100.
  //
  // Increasing/Decreasing Rule is based on round robin.
  //
  function adjustWeight(section, reqId) {
    var reqs = $scope.reqsBySection[section];
    var initiator = null;
    var sum = 0;
    var max = 100;
    var targets = [];
    
    reqs.forEach(function(req) {
      sum += req.weight;

      if(req.isLocked) {
        max -= req.weight;
      }

      if(req.id === reqId) {
        initiator = req;
      }

      if(req.id !== reqId && req.isLocked == false) {
        targets.push(req);
      }

    });

    if(targets.length === 0) {
      initiator.weight = max;
      return;
    }

    if(sum > 100) {
      // slider value increased
      decreaseTarget(sum-100)
    } else {
      // slider value decreased
      increaseTarget(100-sum)
    }

    function decreaseTarget(value) {
      while(value > 0) {
        if(targets.length === 0) {
          // when no other targets exits, decrease initiator.
          initiator.weight -= value;
          value = 0;
          continue;
        }

        var step = SLIDER_STEP;
        targets.forEach(function(req) {

          if(req.weight < step) {
            // this requirement does not have any room to decrease.
            targets.splice(targets.indexOf(req), 1);
            return;
          }

          if(value > 0) {
            req.weight -= step;
            value -= step;
          }
        });
      }
    }
    
    function increaseTarget(value) {
      while(value > 0) {
        if(targets.length === 0) {
          // when no other targets exits, increase initiator.
          initiator.weight += value;
          value = 0;
          continue;
        }

        var step = SLIDER_STEP;
        targets.forEach(function(req) {
          if(value > 0) {
            req.weight += step;
            value -= step;
          }
        });
      }
    }

  }

  // save requirements of section.
  function saveWeight(section) {
    var reqs = $scope.reqsBySection[section];

    reqs.forEach(function(req) {
      $scope.requirements.forEach(function(orgReq) {
        if(req.id === orgReq.id) {
          orgReq.weight = req.weight/100;
          orgReq.$update();
        }
      })
    });
  }

  // slider options
  $scope.sliderOptions = {
    min: 0, 
    max: 100, 
    step: SLIDER_STEP,
    stop: function(evt, ui) {
      // triggered after sliding event finished.
      var section = $(evt.target).data("section");
      var reqId = $(evt.target).data("req-id");
      
      adjustWeight(section, reqId);

      // needs digest to updated adjusted weights.
      $scope.$digest();

      saveWeight(section);
    }
  }

  // sorting options
  $scope.sortableOptions = {
    axis: 'y',
    cursor: "move",
    opacity: 0.7,
    revert: 200,
    placeholder: "well", // class name of drop target
    stop: function(e, ui) { 
      // save sorting result.
      var requirements = $scope.requirements;
      for(var i=0; i< requirements.length; i++) {
        var r = requirements[i];
        // console.log("No.", i+1, r.description, "order = ", r.order_by);

        if(r.order_by === i+1) { continue; } 

        // request will be sent only for the changed requirements.
        r.order_by = i+1;
        r.$update();
      }
    },
  };

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