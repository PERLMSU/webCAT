


$('.note-radio').on('click', function() {
    $(this).find(':radio').prop('checked', true);

});


$(document).on("click", "#save-all-button", function () {

     $( ".draft-form" ).submit();

    $("#all_saved").fadeTo(2000, 500).slideUp(500, function(){
        $("#all_saved").slideUp(500);
    });   

});

$(document).ready(function() {




    $('.draft-form').ajaxForm({ 
        //window.location.reload()
        complete: function(data) {
            if (data.responseJSON["success"] == true)
            {
                var student_id = data.responseJSON["student_id"];     
                var last_updated = data.responseJSON["last_updated"];
                
                if (last_updated.indexOf("PM") >= 0)
                {
                    // var pm = last_updated.indexOf("PM");
                    last_updated = last_updated.replace("PM","p.m.");
                }
                else if (last_updated.indexOf("AM") >= 0)
                {
                    last_updated = last_updated.replace("PM","a.m.");

                }
                //var date = new Date(last_updated.replace(' ', 'T')+'Z');     
               // $('[id^=feedback_]').hide();

             //   $('#feedback_'+String(student_id)).show();           
                $('#feedbackupdated_'+String(student_id)).html(last_updated);
               // $("#saved_"+String(student_id)).show();
               if (data.responseJSON["saved_draft"] == true)
               {
                $("#saved_"+String(student_id)).fadeTo(2000, 500).slideUp(500, function(){
                    $("#saved_"+String(student_id)).slideUp(500);
                }); 
                $("#saved_"+String(student_id)).fadeTo(2000, 500).slideUp(500, function(){
                    $("#saved_"+String(student_id)).slideUp(500);
                });                   
               }
               else
               {

                 $("#status_1_"+String(student_id)).show();

                 $("#confirm-send-to-instructor-"+String(student_id)).modal("toggle");
               //  $("#draft-student-"+String(student_id)).prop('disabled',true);
                 $("#save_send_btns_"+String(student_id)).hide();
                 $("#feedback_"+String(student_id)+' :input').attr("disabled", true);
                 
                 //$("#category_grades_"+String(student_id))+' '
                 
               }
                                  
               
            }
            else
            {
                var student_id = data.responseJSON["student_id"];
                $('#error_'+String(student_id)).fadeTo(2000, 500).slideUp(500, function(){
                    $('#error_'+String(student_id)).slideUp(500);
                });
              //  alert(data.responseJSON["form_errors"]['draft_text']);  
            }             

        }
    }); 
}); 


$( "#createGroupsForm" ).submit(function( event ) {
  //alert( "Handler for .submit() called." );
 
    var num_groups = $(this).children().find('input[name="number_of_groups"]').val()
    if (parseInt(num_groups) < 0)
    {
        $(this).children().closest('div.alert').show()
        event.preventDefault();
    }

});


$( "#nukeStudentsForm" ).submit(function( event ) {
  //alert( "Handler for .submit() called." );
 
    var confirmation_nuke = $("#nuke_em").val()
    if (confirmation_nuke != "Nuke Them All")
    {
        $(this).children().closest('div.alert').show()
        event.preventDefault();
    }

});


$('#submit-selected-drafts').click(function(){
     /* when the submit button in the modal is clicked, submit the form */
    //alert('submitting');
    if ($('.draft-checkbox-row input:checked').length == 0)
    {
        $("#confirm-approve-selected").modal('toggle');
        $("#no-draft-selected-error").show();
     //   alert("No drafts to approve are selected");
       return false; 
    }
   else {
        $('#selected-drafts-form').submit();
   }
    
});
$('#confirm-send-selected-drafts').click(function(){
     /* when the submit button in the modal is clicked, submit the form */
    //alert('submitting');
    if ($('.draft-send-checkbox-row input:checked').length == 0)
    {
        $("#confirm-send-selected").modal('toggle');
        $("#no-draft-selected-error").show();
     //   alert("No drafts to approve are selected");
       return false; 
    }
   else {
        $('#selected-drafts-send-form').submit();
   }
    
});

$('#confirm-resend-selected-drafts').click(function(){
     /* when the submit button in the modal is clicked, submit the form */
    //alert('submitting');
    if ($('.draft-resend-checkbox-row input:checked').length == 0)
    {
        $("#confirm-resend-selected").modal('toggle');
        $("#no-draft-selected-error").show();
     //   alert("No drafts to approve are selected");
       return false; 
    }
   else {
        $('#selected-drafts-resend-form').submit();
   }    
});



$(".draft-checkbox").change(function() {
    if(this.checked) {
        $(this).closest('.draft-highlight').addClass("highlight");
    } else {
    $(this).closest('.draft-highlight').removeClass("highlight");
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
             
    });

});

$('.noteForm').submit(function() {
  
     var that = this;
     var selected = [];
     var index = 0;
     var valid = true;
     $('.student-checkboxes input:checked').each(function() {
          $(that).append('<input type="hidden" name="student_name'+index.toString()+'" value="'+($(this).attr('value'))+'" /> ');
         selected.push($(this).attr('value'));
         index += 1;
     });

     if (index == 0)
     {
        $('#no-student-selected-error').show();       
        valid =false;
     }


     if ($(this).find("input:radio:checked").length != 1 && $(this).find("input:text").val().length == 0)
     {
        $('#no-observation-selected-error').show();  
        valid = false;
     }

      return valid;  
});


$(document).on("click", ".student-feedback", function () {
     var studentId = $(this).data('id');
     $(".feedback-student-writer").hide();
     $("#"+studentId).show();
});

$(document).on("click", ".add-to-feedback-btn", function () {
     var studentID = $(this).data('id');
    var selected = [];
     $('.add-to-feedback-checkboxes input:checked').each(function() {

         selected.push($(this).attr('value'))+' ';         
     });     
     $("#draft-student-"+studentID).append(selected); 
     
     $('input:checkbox').removeAttr('checked');
     $('.modal').modal('hide');
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


$(document).on("click", ".newexplanation", function () {
     var subcategory = $(this).data('id');
     var feedback = $(this).data('feedback');
     var feedback_id = $(this).data('feedbackid');
     $("#edit_explanation_ .new-exp-subcategory").val( subcategory );
     $("#edit_explanation_ .new-explanation").html( feedback );
     $("#edit_explanation_ .new-explanation-fb").val( feedback_id );
});


$(document).on("click", ".newobservation", function () {
     var subcategory = $(this).data('id');
     var subcategoryName = $(this).data('subcategory');
     $("#edit_observation_ .new-obs-subcategory").val( subcategory );
     $("#edit_observation_ .subcategory-name").html( subcategoryName );
});


$(document).on("click", ".newfeedback", function () {
     var subcategory = $(this).data('id');
     var observation = $(this).data('observation');
     var observation_text = $(this).data('observationtext');
     $("#edit_feedback_ .fb-observation").html( observation_text );
     $("#edit_feedback_ .new-fb-subcategory").val( subcategory );
     $("#edit_feedback_ .new-fb-observation").val( observation );
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

$('#confirm-approve-all').on('show.bs.modal', function(e) {    
    var num = $(e.relatedTarget).data('num')
    $("#approve_all_drafts_header").html(num);
    $(this).find('.btn-ok').attr('href', $(e.relatedTarget).data('href'));
});

$('#confirm-send').on('show.bs.modal', function(e) {
    var all = $(e.relatedTarget).data('id')
    var num = $(e.relatedTarget).data('num')
    if (all == "resend")
    {
        $("#email_all_text").html("Are you sure you want resend all emails? This will only resend the drafts that have already been marked as sent.");
        $("#email_header").html("Resend All Drafts ("+num+")");
    }
    else
    {
       $("#email_header").html("Send All Approved Drafts ("+num+")");
        $("#email_all_text").html("Are you sure you want to email all the approved drafts to students for this week? <p>*This will only email the drafts that have not been sent yet.</p>");
    }
    
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
     $('#groups-view').hide();
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
     $('#groups-view').show();
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
