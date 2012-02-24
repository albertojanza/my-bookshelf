// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require_tree .

function search_input(id_location)
{
  var search_input =document.getElementById('book-search'); 
  if (search_input.value == 'Search for books')
  {
      search_input.value = '';
  }

}


function next_slide(slider_index){
  if ((sliders[slider_index][0] ) < (sliders[slider_index][1] -1)) {
   $('#' + slider_index + '-slide-' + sliders[slider_index][0]).fadeOut(500,
    function(){ $( '#' + slider_index + '-slide-' + (sliders[slider_index][0] + 1)).fadeIn(500);
      sliders[slider_index][0] = sliders[slider_index][0] + 1;
       $('#previous_' + slider_index).css('color','#333333');
       $('#previous_' + slider_index).css('cursor','pointer');
      if (sliders[slider_index][0] == (sliders[slider_index][1] - 1)) {
       $('#next_' + slider_index).css('color','#8F8F8F');
       $('#next_' + slider_index).css('cursor','default');
      }

    }  );
  }

}

function previous_slide(slider_index){
  if ((sliders[slider_index][0] ) > 0) {
   $('#' + slider_index + '-slide-' + sliders[slider_index][0]).fadeOut(500,
    function(){ $( '#' + slider_index + '-slide-' + (sliders[slider_index][0] - 1)).fadeIn(500);
      sliders[slider_index][0] = sliders[slider_index][0] - 1 ;
       $('#next_' + slider_index).css('color','#333333');
       $('#next_' + slider_index).css('cursor','pointer');
      if (sliders[slider_index][0] == 0) {
       $('#previous_' + slider_index).css('color','#8F8F8F');
       $('#previous_' + slider_index).css('cursor','default');
      }

    }  );
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

function recommend_friends(){
  $('#recommend-friends').show();
  $('#recommend-selected-friends').hide();
  $('#recommend-read-friends').hide();
  $('#link-recommend-friends').css('background-color','#555555');
  $('#link-recommend-selected-friends').css('background-color','#ffffff');
  $('#link-recommend-read-friends').css('background-color','#ffffff');
  $('#link-recommend-friends').css('color','#ffffff');
  $('#link-recommend-selected-friends').css('color','#555555');
  $('#link-recommend-read-friends').css('color','#555555');

}

function recommend_selected_friends(){
  $('#recommend-friends').hide();
  $('#recommend-selected-friends').show();
  $('#recommend-read-friends').hide();
  $('#link-recommend-friends').css('background-color','#ffffff');
  $('#link-recommend-selected-friends').css('background-color','#555555');
  $('#link-recommend-read-friends').css('background-color','#ffffff');
  $('#link-recommend-friends').css('color','#555555');
  $('#link-recommend-selected-friends').css('color','#ffffff');
  $('#link-recommend-read-friends').css('color','#555555');

}

function recommend_read_friends(){
  $('#recommend-friends').hide();
  $('#recommend-selected-friends').hide();
  $('#recommend-read-friends').show();
  $('#link-recommend-friends').css('background-color','#ffffff');
  $('#link-recommend-selected-friends').css('background-color','#ffffff');
  $('#link-recommend-read-friends').css('background-color','#555555');
  $('#link-recommend-friends').css('color','#555555');
  $('#link-recommend-selected-friends').css('color','#555555');
  $('#link-recommend-read-friends').css('color','#ffffff');

}

function add_friend_recommendation(uid){
  if (recommendation_uid.size == 20)
  {
  $('#recommendation_error_message').html('You can not send more than 20 recommendations at once.')
  $('#recommendation_error_message').show();
  }
  else
  {
    recommendation_uid[uid] = true;
  $('#friend-' + uid ).unbind("click");
    $('#friend-' + uid ).click(function() {
        remove_friend_recommendation(uid);
    });
    $('#friend-' + uid ).css('background-color','#e7e7e7');
    //$('#recommend-selected-friends').append($('#friend-' + uid ).innerHTML);
    $('#recommend-selected-friends').append('<div id="selected-friend-' + uid + '" class="friend-box">' + document.getElementById('friend-' + uid).innerHTML + '</div>');
    $('#selected-friend-' + uid).click(function() {
        remove_friend_recommendation(uid);
    });
  $('#recommendation_error_message').hide();


  }
}

function remove_friend_recommendation(uid){
  delete recommendation_uid[uid];
  $('#recommendation_error_message').hide();
  $('#friend-' + uid ).unbind("click");
    $('#friend-' + uid ).click(function() {
        add_friend_recommendation(uid);
    });
    $('#friend-' + uid ).css('background-color','#ffffff');
    $('#selected-friend-' + uid).remove();
}


function submit_recommendations()
{
  if (recommendation_uid.size == 0)
  {
    $('#recommendation_error_message').html('You haven\'t selected any friend.')
    $('#recommendation_error_message').show();
  }
  else 
  {

    for(var key in recommendation_uid )
    {
      $('#create_recommendations').append('<input type="hidden" value="' + key + '" name="uid[]" id="uid_">');
    }
     $('#create_recommendations').submit();
  }

}


