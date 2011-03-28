// I know that it's ugly, but this is a POC/WIP project.
// TODO:
// * #input should determine (with a special html5 attribute) which session
//   will it talk to
// * #input should know about the updated output too
// * create a convenience function that sets up and handles all the magic

var cuttlebone = {

  sessionId: null,

  init: function() {
    jQuery.ajax({
      type:     'POST',
      url:      '/init',
      dataType: 'json',
      success:  function(d){cuttlebone.updateSessionId(d);cuttlebone.updatePrompt(d);}
    });
  },

  updateSessionId: function(results) {
    cuttlebone.sessionId = results['id'];
  },

  updatePrompt: function(results) {
    if (results) {jQuery('#prompt').html(results['prompt']);w=jQuery('div.input').width();jQuery('div.input span').each(function(){w-=jQuery(this).outerWidth();});jQuery('input#input').width(w-6);}
    else         {jQuery.ajax({type:'POST',url:'/prompt/'+cuttlebone.sessionId,dataType:'json',success:function(d){cuttlebone.updatePrompt(d);}});}
  }

};

jQuery(document).ready(function(){
  cuttlebone.init();
  jQuery('#input').focus();
});

// evaluates input
jQuery('#input').live('keypress', function(e) {
  if (e.keyCode == 13) {
    jQuery.ajax({
      type:     'POST',
      url:      '/call/'+cuttlebone.sessionId,
      data:     {command:jQuery('#input').val()},
      dataType: 'json',
      success:  function(d){
        if (d['output']) {
          jQuery.each(d['output'], function(i,v) {
            jQuery('.output ul').append('<li><pre>'+v+'</pre></li>');
          });
        };
        if (d['error']) {
          jQuery('.output ul').append('<li class="error">'+d['error']+'</li>');
        };
        cuttlebone.updatePrompt(d);
      }
    });
    $(this).val('');
  };
});

