//= require Chart.min

window.addEventListener('load', function () {
  var elem = document.getElementById('funds-by-month');
  if (elem === null) {
    return;
  }
  
  var ctx = elem.getContext('2d');
  var chart = new Chart(ctx, {
      // The type of chart we want to create
      type: 'line',

      // The data for our dataset
      data: funds_by_month_data,

      options: {}
  });
});
