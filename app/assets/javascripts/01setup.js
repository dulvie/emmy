// Setup - a namespace for things that should be run upon document ready.

// @description Hook bootstrap's popover and make it use html instead of a simple string.
var Setup = {
  init:  function()
  {
    this.stateChangeForm();
    this.popover();
    this.submitFormOnSelectChange();
    //this.datepicker();
    this.offcanvasButton();
    this.expandNavigation();
  },

  offcanvasButton: function()
  {
    $('[data-toggle="offcanvas"]').click(function () {
      $('.row-offcanvas').toggleClass('active')
    });
  },

  popover: function()
  {
    $('.popover-wrapper .popover-trigger').popover({
      html: true,
      title: function() { return $(this).parent().find('.head').html(); },
      content: function() {return $(this).parent().find('.content').html();},
      container: 'body',
      placement: 'bottom',
    });
  },

  // @TODO This needs to be more performant. The navigation jumping is not good.
  // Best solution would be to not need javascript at all.
  expandNavigation: function()
  {
    $('#sidebar-menu .dropdown.active a.toggler').click();
    $('#sidebar-menu .dropdown-menu').click(function(event){
      event.stopPropagation();
    });
  },

  stateChangeForm: function()
  {
    $('.state-change-wrapper .toggler').click(function(){
      var $elm = $(this);
      $elm.parent().find('.state-change-form').removeClass('hide');
    });
    $('.state-change-wrapper .reseter').click(function(){
      var $elm = $(this);
      var $wrapper = $elm.parent().parent().parent().parent().parent();
      $wrapper.find('.state-change-form').addClass('hide');
    });
  },

  submitFormOnSelectChange: function()
  {
    $('.submit-on-change').find('select').change(function() {
      $(this).closest('form').submit();
    });
  },


 getQueryParams: function(qs)
 {
    qs = qs.split('+').join(' ');

    var params = {},
        tokens,
        re = /[?&]?([^=]+)=([^&]*)/g;

    while (tokens = re.exec(qs)) {
        params[decodeURIComponent(tokens[1])] = decodeURIComponent(tokens[2]);
    }

    return params;
 }

};

var Calc = {

    toDecimal: function(value)
    {
        if (!typeof value === 'number'){ return 0 };
        return value/100;
    },

    toInteger: function(value) {
        var regexp = /^[0-9]+(\.[0-9]{1,2})?$/;
        if (!regexp.test(value)) {
            return 0
        }
        if (value.indexOf('.') === -1) {
            return value.concat('00')
        }
        if (value.indexOf('.') == value.length - 3) {
            return value.replace('.', '')
        }
        if (value.indexOf('.') == value.length - 2) {
            var v = value.replace('.', '');
            return v.concat('0');
        }
        var v = value.replace('.', '');
        return v.concat('00');
    }
};

$(document).on('turbolinks:load', function(){
  Setup.init();
});