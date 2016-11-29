# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(".root-container.static.index").ready ->
  $(".landing-button").click (e) ->
    element_id = $(e.target).data("element-id");
    console.log(element_id);

    $(".landing-button").removeClass("active");
    $(e.target).addClass("active");

    $(".landing-card-container").addClass("hidden");
    $(".landing-card-container[data-element-id=" + element_id + "]").removeClass("hidden");
