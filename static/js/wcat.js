
  // $("#fb-piece-observation").click(function(){
  //   $("#link").off("click");
  // });

//$(':checkbox').checkboxpicker();

// checkPwd = function() {
//     var str = document.getElementById('pass').value;
//     if (str.length < 6) {
//         alert("too_short");
//         return("too_short");
//     } else if (str.length > 50) {
//         alert("too_long");
//         return("too_long");
//     } else if (str.search(/\d/) == -1) {
//         alert("no_num");
//         return("no_num");
//     } else if (str.search(/[a-zA-Z]/) == -1) {
//         alert("no_letter");
//         return("no_letter");
//     } else if (str.search(/[^a-zA-Z0-9\!\@\#\$\%\^\&\*\(\)\_\+\.\,\;\:]/) != -1) {
//         alert("bad_char");
//         return("bad_char");
//     }
//     alert("oukey!!");
//     return("ok");
// }





$(document).on('change',".observation-dropdown", function(){
 //alert($(this).val());  // will display selected option's value
 //alert($(this).find('option:selected').text()); //will display selected option's text

 if ($(this).find('option:selected').text() == "-")
 {
    $('.observation-new').prop('disabled', false); 
    $(".radio-inline input[type=radio]").prop('disabled', false)

   // $('.observation-new-type').prop('disabled', false); 
 }
 else 
 {
    $('.observation-new').prop('disabled', true); 
    $(".radio-inline input[type=radio]").prop('disabled', true)
 }
 
});  

$(".student-checkbox").change(function() {
    if(this.checked) {
        $(this).closest('.student-checkboxes').addClass("highlight");
    } else {
    $(this).closest('.student-checkboxes').removeClass("highlight");
    }
});

$( "#add-instructor-form" ).submit(function() {
   // event.preventDefault();
    var pw = document.getElementById('id_password').value;
    var confirm_pw = document.getElementById('id_confirm_password').value;
    var pw_valid = true;
    var email_valid = true;
    if (pw.length < 6) {
        pw_valid = false;      
    } else if (pw.length > 50) {
        pw_valid = false; 
    } else if (pw.search(/\d/) == -1) {
        pw_valid = false; 
    } else if (pw.search(/[a-zA-Z]/) == -1) {
        pw_valid = false; 
    } else if (pw.search(/[^a-zA-Z0-9\!\@\#\$\%\^\&\*\(\)\_\+\.\,\;\:]/) != -1) {
        pw_valid = false;
    }

    if (!(confirm_pw === pw)){
        pw_valid = false;
        $('#add-instructor-error-pw-confirm').show();
    }

    if (!(/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(document.getElementById('id_email').value)))
    {
        email_valid = false;
    }

    if (!pw_valid)
    {
        $('#add-instructor-error-pw').show();      
        //return false;   
    }

    if (!email_valid)
    {
        $('#add-instructor-error-email').show();      
        //return false;           
    }
   
    //alert("oukey!!");
    return (pw_valid && email_valid)

  //$( "#add-instructor-form" ).submit();
});

$(document).on('change',".feedback-dropdown", function(){
 //alert($(this).val());  // will display selected option's value
 //alert($(this).find('option:selected').text()); //will display selected option's text

 if ($(this).find('option:selected').text() == "-")
 {
    $('.feedback-new').prop('disabled', false); 

   // $('.observation-new-type').prop('disabled', false); 
 }
 else 
 {
    $('.feedback-new').prop('disabled', true); 
 }
 
});  



$(document).on('change',".explanation-dropdown", function(){
 //alert($(this).val());  // will display selected option's value
 //alert($(this).find('option:selected').text()); //will display selected option's text

 if ($(this).find('option:selected').text() == "-")
 {
    $('.explanation-new').prop('disabled', false); 

 }
 else 
 {
    $('.explanation-new').prop('disabled', true); 
 }
 
});  



$(function() {
    $('#weekDropDown').change(function() {
        this.form.submit();
    });
});

$(document).ready(function(){
    $('[data-toggle="tooltip"]').tooltip(); 
});

$(document).ready(function(){
$(".feedback-student-writer:first").show();



    $('.draft-form').submit(function(e){
        $('.week_number_input').val($('#weekDropDown').val());

    });

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

     if (index == 0)
     {
        $('#no-student-selected-error').show();       
        return false;
     }
      // $('<input />').attr('type', 'hidden')
      //     .attr('name', "something")
      //     .attr('value', "something")
      //     .appendTo(that);
      return true;  
    // alert(selected);
     //return false;
});


$(document).on("click", ".student-feedback", function () {
     var studentId = $(this).data('id');
     $(".feedback-student-writer").hide();
     $("#"+studentId).show();
});



$(document).on("click", ".editstudentrow", function () {
     var studentId = $(this).data('id');
     $(".modal-body #studentId").val( studentId );
});


$(document).on("click", ".create-revision-notes", function () {
     var draft_id = $(this).data('id');
     $(".modal-body #draft_id").val( draft_id );
});

$(document).on("click", ".addsubcategory", function () {
     var main_category_id = $(this).data('id');
     $(".modal-body #main_category").html( main_category_id );
});


$(document).on("click", ".deletecategory", function () {
     var categoryName = $(this).data('id');
     $(".modal-body #categoryName").html( categoryName );
});


$(document).on("click", ".deleteexplanation", function () {
     var deleteName = $(this).data('id');
     $(".modal-body #deleteName").html( deleteName );
});

$(document).on("click", ".newobservation", function () {
     var subcategory = $(this).data('id');
     $(".modal-body #new-obs-subcategory").val( subcategory );
});


$(document).on("click", ".newfeedback", function () {
     var subcategory = $(this).data('id');
     var observation = $(this).data('observation');
     $(".modal-body #new-fb-subcategory").val( subcategory );
     $(".modal-body #new-fb-observation").val( observation );
});

$(document).on("click", ".deleteobservation", function () {
     var observationName = $(this).data('id');
     $(".modal-body #observationName").html( observationName );
});

$('#confirm-delete').on('show.bs.modal', function(e) {
    $(this).find('.btn-ok').attr('href', $(e.relatedTarget).data('href'));
});

$('[id^=confirm-delete]').on('show.bs.modal', function(e) {
    $(this).find('.btn-ok').attr('href', $(e.relatedTarget).data('href'));
});

$('#confirm-approve').on('show.bs.modal', function(e) {
    $(this).find('.btn-ok').attr('href', $(e.relatedTarget).data('href'));
});
$('#confirm-send').on('show.bs.modal', function(e) {
    $(this).find('.btn-ok').attr('href', $(e.relatedTarget).data('href'));
});

$('#confirm-modal').on('show.bs.modal', function(e) {
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
     var instructor_id = $(this).data('instructor');
      var rotationGroupId = $(this).data('rotationgroupid');
      $(".modal-body #assign-group-num").val( groupNum );
     $(".modal-body .hidden-group-num").val( groupNum );
     $(".modal-body #id_instructor_id").val( instructor_id );
     $(".modal-body .hidden-rotation-group").val( rotationGroupId );
     $(".modal-body textarea[name='group_description']").val( description );
     $(".modal-body .assign-group-num").html( groupNum );
});

$(document).on("click", ".all-notes-view", function () {
     // var category_pk = this.id;
     $('[id^="sub_categories_"]').hide();
     $('#main_categories').hide();
     $('#all_notes_view').show();
});

$(document).on("click", ".main-category-btn", function () {
     var category_pk = this.id;
     $("#sub_categories_"+category_pk).show();
     $('#main_categories').hide();
     $('#all_notes_view').hide();
     // $(".modal-body #categoryName").html( categoryName );
});


$(document).on("click", ".back-to-main-categories", function () {
     $('#main_categories').show();
     $('#all_notes_view').hide();
     $('[id^="sub_categories_"]').hide();
     // $(".modal-body #categoryName").html( categoryName );
});

$(document).on("click", ".sub-category-btn", function () {
     var category_pk = this.id;
     if ($("#note_taker_"+category_pk).is(":visible"))
     {
        $("#note_taker_"+category_pk).hide("slow");
     }
     else
     {
        $("#note_taker_"+category_pk).show("slow");
     }     
     //$("#note_taker_"+category_pk).show();
     $('#main_categories').hide();
     $('#all_notes_view').hide();
     // $(".modal-body #categoryName").html( categoryName );
});
