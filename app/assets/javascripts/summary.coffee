# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
drawChart = (data) ->
  if data.unavailable
    $("#historical-chart").addClass("hidden");
    $("#chart_unavailable").removeClass("hidden")
  else
    # Generate chart
    vis = d3.select("#historical-chart")

    # Remove existing chart (in case we're re-drawing due to a period change)
    vis.selectAll("*").remove();

    # Generate scales
    x = d3.scaleTime()
    y = d3.scaleLinear()

    # Parse times
    timeParser = d3.timeParse("%m/%d/%Y")
    for dataSet in data
      for dataPoint in dataSet.data
        dataPoint.time = timeParser(dataPoint.time)

    # Create line generator
    lineGenXFunc = (d) ->
      x(d.time)
    lineGenYFunc = (d) ->
      y(d.as_float)
    lineGen = d3.line()
      .x(lineGenXFunc)
      .y(lineGenYFunc)
      .curve(d3.curveBasis);

    # Create axes from scale
    xAxis = d3.axisBottom(y)
    yAxis = d3.axisLeft(y)

    # Set X domain
    dataPoints = []
    data.forEach (dataSet) ->
      dataSet.data.forEach (dataPoint) ->
        dataPoints.push(dataPoint)
    xFunc = (d) ->
      return d.time;
    x.domain(d3.extent(dataPoints, xFunc));

    # Set Y domain
    yFuncMin = (a) ->
      yFuncInternal = (d) ->
        return d.as_float;
      return d3.min(a.data, yFuncInternal);
    yFuncMax = (a) ->
      yFuncInternal = (d) ->
        return d.as_float;
      return d3.max(a.data, yFuncInternal);
    y.domain([
      d3.min(data, yFuncMin),
      d3.max(data, yFuncMax)
    ]);

    # Create containers for each element
    xAxisSvg = vis.append("svg:g")
    yAxisSvg = vis.append("svg:g")
    lineMetadata = []
    for dataSet in data
      lineMetadata.push({
        data: dataSet,
        lineSvg: vis.append('svg:path')
      })

    # Render data into containers + set a listener to re-render on resize
    reRender = ( )->
      renderIntoContainers(x, y, xAxis, yAxis, xAxisSvg, yAxisSvg, lineMetadata, lineGen)
    reRender()
    window.addEventListener("resize", reRender);

renderIntoContainers = (x, y, xAxis, yAxis, xAxisSvg, yAxisSvg, lineMetadata, lineGen) ->
  # Rescale x/y ranges
  x.range([getDimensions().margins.left, getDimensions().width - getDimensions().margins.right])
  y.range([getDimensions().height - getDimensions().margins.top, getDimensions().margins.bottom])

  # Rescale axes based on new x/y ranges
  xAxis.scale(x);
  yAxis.scale(y);

  # Re-render axes
  xAxisSvg
    .attr("transform", "translate(0," + (getDimensions().height - getDimensions().margins.bottom) + ")")
    .call(xAxis);
  yAxisSvg
    .attr("transform", "translate(" + (getDimensions().margins.left) + ",0)")
    .call(yAxis);

  # Re-render text/lines, and grab metadata for legend
  for lineMetadataEntryIndex of lineMetadata
    lineMetadataEntry = lineMetadata[lineMetadataEntryIndex]

    lineMetadataEntry.lineSvg
      .attr('d', lineGen(lineMetadataEntry.data.data))
      .attr('stroke', lineMetadataEntry.data.color)
      .attr('stroke-width', 2)
      .attr('fill', 'none');

  # Rotate labels 90 degrees
  xAxisSvg
    .selectAll("text")
    .attr("y", 0)
    .attr("x", 9)
    .attr("dy", ".35em")
    .attr("transform", "rotate(90)")
    .style("text-anchor", "start");

getDimensions = () ->
  {
    margins: {
      top: 50,
      right: 0,
      bottom: 50,
      left: 100
    },
    width: window.innerWidth * 0.6,
    height: 500
  }

getDataAndDrawChart = () ->
  period = $("select[name=period]").val()

  $.ajax '/summary/get_chart_data?period=' + period,
    type: 'GET'
    dataType: 'json'
    error: (result) ->
      alert("Unable to render chart!  Please try again.")
    success: (data) ->
      drawChart(data)

$(".root-container.summary.index").ready ->
  if $(".alert-warning").data("page-disabled") != true
    getDataAndDrawChart()

  $("select[name=period]").change ->
    getDataAndDrawChart()

  $("select[name=currency]").change ->
    if $("select[name=currency]").val() != "Currency"
      $("#currency_form").submit()

  $(".account-balance-tooltip-content").each (index, element) ->
    accountId = $(element).data("accountId")
    content = $(element).html()

    $(".account-balance-tooltip[data-account-id=" + accountId + "]").popover(
      html: true,
      content: content,
      placement: "right",
      trigger: "hover"
    )
