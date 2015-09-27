app.controller('employee_form_ctrl', function ($scope, $modal) {

    $scope.init = function() {
    	var begin = $('#in_begin').val().split(/\D/);
		begin.length == 1 ? $scope.begin_date = new Date() : $scope.begin_date = new Date(begin[0], --begin[1], begin[2]);

		var ending = $('#in_ending').val().split(/\D/);
		ending.length == 1 ? $scope.ending_date = new Date() : $scope.ending_date = new Date(ending[0], --ending[1], ending[2]);
	};

	$scope.begin_options = {'starting-day': 1,'show-weeks': false};
	$scope.open_begin_date = function($event) {
		$event.preventDefault();
		$event.stopPropagation();
		$scope.begin_open = true;
	};

	$scope.ending_options = {'starting-day': 1,'show-weeks': false};
	$scope.open_ending_date = function($event) {
		$event.preventDefault();
		$event.stopPropagation();
		$scope.ending_open = true;
	};
	
	$scope.show_info = function($event, content) {
	  var text = new Array;
	  switch(content) {
	    case 'tax_table_column':
	      text[0] = "I de flesta fall gäller kolumn 1."
        text[1] = "Kolumn 1 avser löner, arvoden och liknande ersättningar till den som är född 1949 eller senare. Allmän pensionsavgift ska betalas och inkomsten ger rätt till jobbskatteavdrag."
        text[2] = "Kolumn 2 avser sådana inkomster (t.ex. pensioner) till den som är född 1948 eller tidigare, som inte är underlag för allmän pensionsavgift och inte ger rätt till jobbskatteavdrag."
        text[3] = "Kolumn 3 avser löner, arvoden och liknande ersättningar till den som är född 1938–1948. Allmän pensionsavgift ska betalas och inkomsten ger rätt till ett högre jobbskatteavdrag än enligt kolumn 1."
        text[4] = "Kolumn 4 avser löner, arvoden och liknande ersättningar till den som är född 1937 eller tidigare. Allmän pensionsavgift ska inte betalas. Inkomsten ger samma rätt till jobbskatteavdrag som enligt kolumn 3."
        text[5] = "Kolumn 5 avser andra pensionsgrundande ersättningar än löner m.m., t.ex. ersättning från arbetslöshetskassa och egen arbetsskadelivränta, till den som är född 1938 eller senare. Allmän pensionsavgift ska betalas på inkomsten men denna ger inte rätt till jobbskatteavdrag." 
        text[6] = "Kolumn 6 avser sådana inkomster (t.ex. pensioner) till den som är född 1949 eller senare, som inte är underlag för allmän pensionsavgift och inte ger rätt till jobbskatteavdrag."
	      break;
	    case 'clearingnumber':
	      text[0] = "Identifikation av bankkontoret. Nödvändigt om löner utbetalas via fil till banken."
	      text[1] = "Mer information hittas på  http://clearingnummer.info/"
	      break;
	    default:
	      text[0] = "Inget att visa";
	  }; 
	  $scope.open_message('mb', 'infoContent', text);
	  $event.preventDefault();
    $event.stopPropagation();
	};

  $scope.open_message = function (size, el, messages) {
    $scope.messages = messages;
    var elem = '#'+el;
    var temp = $(elem).html();
    var modalInstance = $modal.open({
      template: temp,
      controller: 'ModalInfoInstanceCtrl',
      size: size,
      resolve: {
        messages: function () {
          return $scope.messages;
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

app.controller('ModalInfoInstanceCtrl', function ($scope, $modalInstance, messages) {
  $scope.messages = messages;
  $scope.openDate = function($event) {
    $event.preventDefault();
    $event.stopPropagation();
    $scope.isOpen = true;
  };

  $scope.cancel = function () {
    $modalInstance.dismiss('cancel');
  };
});