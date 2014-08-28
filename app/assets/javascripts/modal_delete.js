app.controller('ModalDeleteCtrl', function ($scope, $modal, $log) {
	$scope.open = function ($event, size, el, o) {
		$scope.obj = o;
		var elem = '#'+el;
		var temp = $(elem).html();
		var modalInstance = $modal.open({
			template: temp,
			controller: 'ModalInstanceCtrl',
			size: size,
			resolve: {
				obj: function () {
					return $scope.obj;
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

app.controller('ModalInstanceCtrl', function ($scope, $modalInstance, obj) {
	$scope.obj = obj;
	$scope.ok = function ($event) {
		$event.preventDefault();
		$event.stopPropagation();
	};

	$scope.cancel = function () {
		$modalInstance.dismiss('cancel');
	};
});