$(document).ready(function(){

    $('.draft-formm').submit(function(e){
        e.preventDefault();
        //var csrftoken = getCookie('csrftoken');
        var that = $(this);
          $.ajax({
            url: "/feedback/edit-draft/",
            type: 'POST',
            data: {
              'student_pk': that.children()[2].value,
              'text': that.children().find('.form-control').val(),
              'csrfmiddlewaretoken': that.children()[0].value,
            },
            dataType: 'json',
            success: function (data) {
                alert("got here, data: ", data);
              // if (data.is_taken) {
              //   alert("A user with this username already exists.");
              // }
            }
          });    


        // $.post('/feedback/edit_draft', $(this).serialize(), function(data){ ... 
        //    $('.message').html(data.message);
        //    // of course you can do something more fancy with your respone
        // });
         
    });

// using jQuery
// function getCookie(name) {
//     var cookieValue = null;
//     if (document.cookie && document.cookie !== '') {
//         var cookies = document.cookie.split(';');
//         for (var i = 0; i < cookies.length; i++) {
//             var cookie = jQuery.trim(cookies[i]);
//             // Does this cookie string begin with the name we want?
//             if (cookie.substring(0, name.length + 1) === (name + '=')) {
//                 cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
//                 break;
//             }
//         }
//     }
//     return cookieValue;
// }


    // $.ajaxSetup({
    //          beforeSend: function(xhr, settings){
    //              function getCookie(n) {
    //                  var cookieValue = null;
    //                  if(document.cookie&&document.cookie != ''){
    //                      var cookies = document.cookie.split(';');
    //                      for(var i = 0; i < cookies.length; i++){
    //                          var cookie = jQuery.trim(cookies[i]);
    //                          if(cookie.substring(0, n.length + 1) == (n + '=')){
    //                              cookieValue = decodeURIComponent(cookie.substring(n.length + 1));
    //                              break;
    //                          }
    //                      }
    //                  }
    //                  return cookieValue;
    //              }
    //              if(!(/^http:.*/.test(settings.url) || /^https:.*/.test(settings.url))){
    //                  xhr.setRequestHeader("X-CSRFToken", getCookie('csrftoken'));
    //              }
    //          }
    //     });

});

$('.noteForm').submit(function() {
  // your code here
     var that = this;
     var selected = [];
     var index = 0;
     $('.student-checkboxes input:checked').each(function() {
          $(that).append('<input type="hidden" name="student_name'+index.toString()+'" value="'+($(this).attr('value'))+'" /> ');
         selected.push($(this).attr('value'));
         index += 1;
     });
      // $('<input />').attr('type', 'hidden')
      //     .attr('name', "something")
      //     .attr('value', "something")
      //     .appendTo(that);
      return true;  
    // alert(selected);
     //return false;
});



$(document).on("click", ".editstudentrow", function () {
     var studentId = $(this).data('id');
     $(".modal-body #studentId").val( studentId );
});


$(document).on("click", ".addsubcategory", function () {
     var main_category_id = $(this).data('id');
     $(".modal-body #main_category").html( main_category_id );
});


$(document).on("click", ".deletecategory", function () {
     var categoryName = $(this).data('id');
     $(".modal-body #categoryName").html( categoryName );
});

$('#confirm-delete').on('show.bs.modal', function(e) {
    $(this).find('.btn-ok').attr('href', $(e.relatedTarget).data('href'));
});


$(document).on("click", ".deletestudent", function () {
     var studentName = $(this).data('id');
     $(".modal-header .student-or-group").html(" Student")
     $(".warning-delete-group").hide();
     $(".modal-body #del_name").html( studentName );
});

$(document).on("click", ".deletegroup", function () {
     var groupName = $(this).data('id');
     $(".modal-header .student-or-group").html(" Group")
     $(".warning-delete-group").show();
     $(".modal-body #del_name").html( groupName );
});



$(document).on("click", ".assigngroup", function () {
     var groupNum = $(this).data('id');
     var description = $(this).data('info'); 
     $(".modal-body .hidden-group-num").val( groupNum );
     $(".modal-body input[name='group_description']").val( description );
     $(".modal-body #assign-group-num").html( groupNum );
});


$(document).on("click", ".main-category-btn", function () {
     var category_pk = this.id;
     $("#sub_categories_"+category_pk).show();
     $('#main_categories').hide();
     // $(".modal-body #categoryName").html( categoryName );
});


$(document).on("click", ".back-to-main-categories", function () {
     $('#main_categories').show();
     $('[id^="sub_categories_"]').hide();
     // $(".modal-body #categoryName").html( categoryName );
});

$(document).on("click", ".sub-category-btn", function () {
     var category_pk = this.id;
     $("#note_taker_"+category_pk).show();
     $('#main_categories').hide();
     // $(".modal-body #categoryName").html( categoryName );
});
