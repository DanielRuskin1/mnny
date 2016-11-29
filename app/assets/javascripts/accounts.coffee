# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(".root-container.accounts.index").ready ->
  $("#create-balance-datepicker-field").datepicker({
    format: "mm/dd/yyyy"
  });

  $(document).on "change", ".asset-type-dropdown", (e) ->
    account_id = $(e.target).parent().data("account-id");
    if $(e.target).val() == "stock"
      $("#account_" + account_id).find(".currency-dropdown").attr("disabled", true);
      $("#account_" + account_id).find(".currency-dropdown-div").addClass("hidden")

      $("#account_" + account_id).find(".stock-field").removeAttr("disabled");
      $("#account_" + account_id).find(".stock-field-div").removeClass("hidden");
    else
      $("#account_" + account_id).find(".stock-field").attr("disabled", true);
      $("#account_" + account_id).find(".stock-field-div").addClass("hidden")

      $("#account_" + account_id).find(".currency-dropdown").removeAttr("disabled");
      $("#account_" + account_id).find(".currency-dropdown-div").removeClass("hidden");
