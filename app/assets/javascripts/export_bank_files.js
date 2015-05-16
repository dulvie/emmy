app.controller('export_bank_file_form_ctrl', function ($scope) {

  $scope.init = function() {

    var ex = $('#in_export_date').val().split(/\D/);
    ex.length == 1 ? $scope.ex_date = new Date() : $scope.ex_date = new Date(ex[0], --ex[1], ex[2]);

    var from = $('#in_from_date').val().split(/\D/);
    from.length == 1 ? $scope.from_date = new Date() : $scope.from_date = new Date(from[0], --from[1], from[2]);

    var to = $('#in_to_date').val().split(/\D/);
    to.length == 1 ? $scope.to_date = new Date() : $scope.to_date = new Date(to[0], --to[1], to[2]);

  };

  $scope.ex_options = {'starting-day': 1,'show-weeks': false};
  $scope.open_ex = function($event) {
    $event.preventDefault();
    $event.stopPropagation();
    $scope.ex_open = true;
  };

  $scope.from_options = {'starting-day': 1,'show-weeks': false};
  $scope.open_from = function($event) {
    $event.preventDefault();
    $event.stopPropagation();
    $scope.from_open = true;
  };

  $scope.to_options = {'starting-day': 1,'show-weeks': false};
  $scope.open_to = function($event) {
    $event.preventDefault();
    $event.stopPropagation();
    $scope.to_open = true;
  };
});