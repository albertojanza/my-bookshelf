// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

function next_slide(slider_index){
  if ((sliders[slider_index][0] + 1) < sliders[slider_index][1]) {
   $('#' + slider_index + '-bookshelf-slide-' + sliders[slider_index][0]).fadeOut(500,function(){ $( '#' + slider_index + '-bookshelf-slide-' + (sliders[slider_index][0] + 1)).fadeIn(500);sliders[slider_index][0] = sliders[slider_index][0] + 1;}  );
  }

}

function previous_slide(slider_index){
  if ((sliders[slider_index][0] ) > 0) {
   $('#' + slider_index + '-bookshelf-slide-' + sliders[slider_index][0]).fadeOut(500,function(){ $( '#' + slider_index + '-bookshelf-slide-' + (sliders[slider_index][0] - 1)).fadeIn(500);sliders[slider_index][0] = sliders[slider_index][0] - 1 ;}  );
  }

}

// This function are from the first version of the jquery effects applied to the stream widget
function replacing_tweet(pointer,limit,twitter_id){
    if ($('#' + twitter_id +'_item_' + (pointer + 5)).length > 0 ) {
      $( '#' + twitter_id +'_item_' + pointer).hide(500,function(){ $( '#' + twitter_id +'_item_' + (pointer + 5)).show(500);}  );
    }
    if ((pointer + 1) < limit) {
        setTimeout("replacing_tweet(" + (pointer + 1) + "," + limit + "," + twitter_id +");", 2000);
    }


}

function updating_twitter_stream(pointer_to_new_tweets,queue_size,url,twitter_id){


    replacing_tweet(pointer_to_new_tweets,pointer_to_new_tweets + 5,twitter_id);
    if ((pointer_to_new_tweets + 5) < queue_size - 5 ) {
      setTimeout("updating_twitter_stream(" + (pointer_to_new_tweets + 5) + "," + queue_size + ",'" + url + "','" + twitter_id + "');", 20000);
    }
    else {
            //alert("#stream_" + twitter_id);
        timeout = setTimeout(function() {
            $("#stream_" + twitter_id ).load(url);  
        },20000);
    }


}


