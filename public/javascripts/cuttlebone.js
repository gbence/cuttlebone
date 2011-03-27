// I know that it's ugly, but this is a POC/WIP project.
// TODO:
// * get rid of that global variable
// * #input should determine (with a special html5 attribute) which session
//   will it talk to
// * #input should know about the updated output too
// * create a convenience function that sets up and handles all the magic

var cuttlebone_session_id;

jQuery(document).ready(function(){
  // updates prompt
  jQuery.ajax({type:'POST',url:"/init",dataType:"json",success:function(d){if(d['id']){cuttlebone_session_id=d['id'];};if(d['prompt']){jQuery('#prompt').html(d['prompt']);};}});
});

// evaluates input
jQuery("#input").live("keypress", function(e) {
  if (e.keyCode == 13) {
    jQuery.ajax({
      type:     "POST",
      url:      "/call/"+cuttlebone_session_id,
      data:     {command:jQuery('#input').val()},
      dataType: "json",
      success:  function(d){
        if (d['output']) {
          jQuery.each(d['output'], function(i,v) {
            jQuery('.output ul').append('<li><pre>'+v+'</pre></li>');
          });
        };
        if (d['error']) {
          jQuery('.output ul').append('<li class="error">'+d['error']+'</li>');
        };
        if (d['prompt']) {
          jQuery('#prompt').html(d['prompt']);
        }
      }
    });
    $(this).val('');
  };
});

