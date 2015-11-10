app.controller('accounting_plan_form_ctrl', function ($scope, $modal, $sce) {

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
