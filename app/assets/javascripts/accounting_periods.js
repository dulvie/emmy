app.controller('accounting_period_form_ctrl', function ($scope, $modal, $sce) {

    $scope.init = function() {
    	var from = $('#in_from').val().split(/\D/);
		from.length == 1 ? $scope.from_date = new Date() : $scope.from_date = new Date(from[0], --from[1], from[2]);

		var to = $('#in_to').val().split(/\D/);
		to.length == 1 ? $scope.to_date = new Date() : $scope.to_date = new Date(to[0], --to[1], to[2]);

	};

	$scope.from_options = {'starting-day': 1,'show-weeks': false};
	$scope.open_from_date = function($event) {
		$event.preventDefault();
		$event.stopPropagation();
		$scope.from_open = true;
	};

	$scope.to_options = {'starting-day': 1,'show-weeks': false};
	$scope.open_to_date = function($event) {
		$event.preventDefault();
		$event.stopPropagation();
		$scope.to_open = true;
	};

    $scope.show_info = function($event, info) {
        $scope.open_info('mb', 'infoContent', info);
        $event.preventDefault();
        $event.stopPropagation();
    };

    $scope.open_info = function (size, el, info) {
        var info_el= '#'+info;
        var info_html = $(info_el).html();
        $scope.info = $sce.trustAsHtml(info_html);
        var elem = '#'+el;
        var temp = $(elem).html();
        var modalInstance = $modal.open({
            template: temp,
            controller: 'ModalInfoInstanceCtrl',
            size: size,
            resolve: {
                info: function () {
                    return $scope.info;
                }
            }
        });
        modalInstance.result.then(function (selectedItem) {
            $scope.selected = selectedItem;
        }, function () {
        });
    };

});