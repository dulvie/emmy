app.controller('search_account_ctrl', function ($scope) {
  $scope.accounting_groups = gon.accounting_groups;
  $scope.accounts = gon.accounts;
  
	$scope.init = function(account, description) {
        $scope.account = '#'+account;
        $scope.description = '#'+description;
	};

	$scope.select_accounting_group = function() {
	      set_first_account($scope.accounting_group);
        
	};
    $scope.select_account = function() {
        for (x=0; x < $scope.accounts.length; x++) {
            if ($scope.accounts[x].number == $scope.acc) {
                $($scope.account).val($scope.accounts[x].id);
                $($scope.description).val($scope.accounts[x].description);
            }
        }
    };
    function set_first_account(group_id){
       var first = true;
       for (x=0; x < $scope.accounts.length && first; x++) {
         if ($scope.accounts[x].accounting_group_id == group_id) {
           $scope.acc = $scope.accounts[x].number;
           $($scope.account).val($scope.accounts[x].id);
           $($scope.description).val($scope.accounts[x].description);
           first = false;
         }
       }
    }
});