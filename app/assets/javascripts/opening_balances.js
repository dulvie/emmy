app.controller('opening_balance_form_ctrl', function ($scope) {

   $scope.init = function() {
        var min_date = $('#allow_from').val();
        var max_date = $('#allow_to').val();
        set_date(min_date, max_date);
   };

    function set_date(min, max) {
        $scope.min_date = min;
        $scope.max_date = max;
    }
});