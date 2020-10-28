//= require Chart.min

window.addEventListener('load', function () {
  var elem = document.getElementById('flow-by-month');
  console.log(elem);
  var ctx = elem.getContext('2d');
  var chart = new Chart(ctx, {
      // The type of chart we want to create
      type: 'line',

      // The data for our dataset
      data: flow_by_month_data,

      // Configuration options go here
      options: {}
  });

  var elem = document.getElementById('totals-by-month');
  var ctx = elem.getContext('2d');
  var chart = new Chart(ctx, {
      // The type of chart we want to create
      type: 'line',

      // The data for our dataset
      data: totals_by_month_data,

      // Configuration options go here
      options: {}
  });
});
