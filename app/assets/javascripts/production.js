app.controller('production_form_ctrl', function ($scope, $modal, $sce) {

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
            //$log.info('Modal dismissed at: ' + new Date());
        });
        //$event.preventDefault();
        //$event.stopPropagation();
    };
});


app.controller('production_material_form_ctrl', function ($scope, $modal, $sce) {

    $scope.init = function() {
        $scope.shelf_qty = 0;
        var idx = $('#material_batch_id').val();
        for (x=0; x < gon.shelves.length; x++) {
            if (gon.shelves[x].batch_id == idx) {
                $scope.shelf_qty = gon.shelves[x].quantity;
                $scope.bch = gon.shelves[x].batch_id;
                $scope.set_unit();
            }
        }
    };
    $scope.set_unit = function() {
        for (x=0; x < gon.batches.length; x++) {
          if (gon.batches[x].id == $scope.bch) {
            $('#material_unit').val(gon.batches[x].unit.name);
          }
        };

    };
	$scope.change_batch = function() {
		for (x=0; x < gon.shelves.length; x++) {
			if (gon.shelves[x].batch_id == $scope.bch) {
				$scope.shelf_qty = gon.shelves[x].quantity;
				$scope.set_unit();
			}
		}
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
            //$log.info('Modal dismissed at: ' + new Date());
        });
        //$event.preventDefault();
        //$event.stopPropagation();
    };
});
app.controller('production_batch_ctrl', function ($scope, price, $modal, $sce) {

    var item = {};

	$scope.init = function() {
		$scope.refined = true;
		$scope.sales = true;
		$scope.item_id = $('#production_batch_item_id').val();
		var default_price = false;
		if ($('#production_batch_distributor_price').val()=='')
			default_price = true;
		var ex = $('#in_expire_at').val().split(/\D/);
		ex.length == 1 ? $scope.ex_date = new Date() : $scope.ex_date = new Date(ex[0], --ex[1], ex[2]);

		var re = $('#in_refined_at').val().split(/\D/);
		re.length == 1 ? $scope.re_date = new Date() : $scope.re_date = new Date(re[0], --re[1], re[2]);
		
		$scope.select_item(default_price);
	};

	$scope.ex_options = {'starting-day': 1,'show-weeks': false};
	$scope.open_ex_date = function($event) {
		$event.preventDefault();
		$event.stopPropagation();
		$scope.ex_open = true;
	};

	$scope.re_options = {'starting-day': 1,'show-weeks': false};
	$scope.open_re_date = function($event) {
		$event.preventDefault();
		$event.stopPropagation();
		$scope.re_open = true;
	};

    $scope.calc_retail = function() {
        var price = Number($('#retail_price_edit').val());
        var moms = Number(price * item.vat_add_factor);
        var ink_moms = (price + moms).toFixed(2);
        $('#production_batch_retail_inc_vat').val(ink_moms);
    };
    $scope.calc_distributor = function() {
        var price = Number($('#distributor_price_edit').val());
        var moms = Number(price * item.vat_add_factor);
        var ink_moms = (price + moms).toFixed(2);
        $('#production_batch_distributor_inc_vat').val(ink_moms);
    };

	$scope.select_item = function(default_price) {
		$scope.refined = true;
		$scope.sales = true;
  		for (x=0; x < gon.items.length; x++) {
			if (gon.items[x].id == $scope.item_id) {
              item = gon.items[x];
			  var d = new Date();
			  if (default_price)
			    $('#production_batch_name').val(gon.items[x].name + " " + d.getFullYear() + ":" + (d.getMonth()+1))
                $('#production_batch_unit').val(gon.items[x].unit.name);
				$('#in_price_edit').val(price.toDecimal(gon.items[x].in_price));
				if (default_price)
					$('#production_batch_distributor_price').val(gon.items[x].distributor_price);
				if (default_price)
					$('#production_batch_retail_price').val(gon.items[x].retail_price);
				$('#distributor_price_edit').val(price.toDecimal($('#production_batch_distributor_price').val()));
				$('#retail_price_edit').val(price.toDecimal($('#production_batch_retail_price').val()));
                $scope.calc_retail();
                $scope.calc_distributor();
				if (gon.items[x].item_group == 'refined') {
					$scope.refined = false;
				}
				if ((gon.items[x].item_type == 'sales') || (gon.items[x].item_type == 'both')) {
					$scope.sales = false;
				}
			}
		}
	};
	$scope.before_submit = function() {
    	$('#production_batch_in_price').val(price.toInteger($('#in_price_edit').val()));
    	$('#production_batch_distributor_price').val(price.toInteger($('#distributor_price_edit').val()));
    	$('#production_batch_retail_price').val(price.toInteger($('#retail_price_edit').val()));
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
            //$log.info('Modal dismissed at: ' + new Date());
        });
        //$event.preventDefault();
        //$event.stopPropagation();
    };
});