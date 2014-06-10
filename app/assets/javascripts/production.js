//var ModalInstanceCtrl = function ($scope, items) {
app.controller('ModalDemoCtrl', function ($scope, $modal, $log) {
  $scope.items = ['item1', 'item2', 'item3'];

  
  $scope.open = function ($event, size, el) {

    var elem = '#'+el;
    //var p = $('#myModalContent').html()
    var p = $(elem).html();
    
    var modalInstance = $modal.open({
      template: p,
      controller: 'ModalInstanceCtrl',
      size: size,
      resolve: {
        items: function () {
          return $scope.items;
        }
      }
    });

    modalInstance.result.then(function (selectedItem) {
      $scope.selected = selectedItem;
    }, function () {
      $log.info('Modal dismissed at: ' + new Date());
    });
	$event.preventDefault();
	$event.stopPropagation();	   
  };
});

//var ModalInstanceCtrl = function ($scope, $modalInstance, items) {
app.controller('ModalInstanceCtrl', function ($scope, $modalInstance, items) {
	$scope.date = new Date();
	  $scope.dpOptions = {
			    'starting-day': 1,
			    'show-weeks': false
			  };
		//$scope.isOpen = false;
		
	$scope.openDate = function($event) {
		$event.preventDefault();
		$event.stopPropagation();
        $scope.isOpen = true;
	};
	
	  $scope.items = items;
	  $scope.selected = {
	    item: $scope.items[0]
	  };

	  $scope.ok = function ($event) {
		var el = $('#edit_costitem_15');
		
		//  alert($('#edit_costitem_15'));
		el.submit();	
	    $modalInstance.close($scope.selected.item);
		//$event.preventDefault();
		//$event.stopPropagation();	
	  };

	  $scope.cancel = function () {
	    $modalInstance.dismiss('cancel');
	  };
	  $scope.sbm = function($event) {
		  var e = $('#edit_costitem_15')
		  $( "form:last" ).submit();
		  //e.submit();
		  alert('NU');
	//alert(	  $(this).closest('form').attr('id'));
  
			//$event.preventDefault();
			//$event.stopPropagation();	  		  
	  };
	});