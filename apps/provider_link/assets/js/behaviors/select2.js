onmount('form[name="loa_consult"]', function(){
  $('select[id="diagnosis"]').select2({
    placeholder: "Select Diagnosis",
    theme: "bootstrap",
    minimumInputLength: 3
  });

  $('select[id="doctor"]').select2({
    placeholder: "Select Diagnosis",
    theme: "bootstrap",
    minimumInputLength: 3
  });
});

onmount('form[name="add_to_batch"]', function(){
  $('select[id="loa_batch_batch_no"]').select2({
    placeholder: "Enter Batch No.",
    theme: "bootstrap",
    minimumInputLength: 3,
    language: {
             noResults: function(term) {
                 return "No records found.";
            }
        }
  });
});
