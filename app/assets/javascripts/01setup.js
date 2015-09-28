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
      //placement: function() {return $(this).data('placement')},
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
 },

}
