app.controller('purchase_items_form_ctrl', function ($scope, $filter, price, $modal, $sce) {
	
	$scope.show_batch = false;
  var o = $("#purchase_item_item_id").val();
	$scope.item_id = o;
	var p = $('#purchase_item_price').val();
	var pri = true;
  if (p == '') {
  	pri = false;
  }
  $scope.before_submit = function() {
   	$('#purchase_item_price').val(price.toInteger($('#price_edit').val()));
  };

    $scope.item_changed = function() {
        $scope.show_batch = false;
        $scope.batch = {};
        for (var x=0; x < gon.items.length; x++) {
            if ($scope.item_id == gon.items[x].id) {
                $scope.options = gon.items[x].batches;
                $scope.unit = gon.items[x].unit.name;
                if (pri) {
                    $('#price_edit').val(price.toDecimal(p));
                    pri = false;
                }
                else {
                    var pr = gon.items[x].in_price;
                    $('#price_edit').val(price.toDecimal(pr));
                }
                if (typeof($scope.options[0]) != "undefined") {
                    $scope.batch.id = $scope.options[0].id;
                    $scope.show_batch = true;
                }
                if (gon.items[x].stocked) {
                    $scope.show_batch = true;
                }
            }
        }
    }
    $scope.item_changed();

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