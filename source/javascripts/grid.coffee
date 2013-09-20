render = ->
  width  = $(document.body).width()
  height = 280
  gridWidth = Math.round(width / 4) - 41
  colors = ['#1a1a1a', '#353535', '#555', '#757575', '#959595', '#b5b5b5', '#d5d5d5', '#f5f5f5']

  fill = d3.scale.quantile().range colors

  projection  = d3.geo.albers().scale(1).translate [ 0, 0 ]
  path = d3.geo.path().projection(projection)

  d3.json 'data/pdx.json', (pdx) ->
    $('.js-loading').hide()

    items = d3.select('.js-grid').selectAll('.item')
      .data(d3.entries(__mappings))
    .enter().append('div')
      .attr('class', 'item')

    items.append('h3')
      .attr('class', 'title')
      .text((d) -> d.key)

    blockgroups = topojson.feature pdx, pdx.objects.pdx
    water       = topojson.feature pdx, pdx.objects.water
    parks       = topojson.feature pdx, pdx.objects.parks

    projection.scale(1).translate([0, 0])
    b = path.bounds(blockgroups)
    s = .99 / Math.max((b[1][0] - b[0][0]) / gridWidth, (b[1][1] - b[0][1]) / height)
    t = [(gridWidth - s * (b[1][0] + b[0][0])) / 2, (height - s * (b[1][1] + b[0][1])) / 2]
    projection.scale(s).translate(t)

    items.each (mapping) ->
      canvas = d3.select(this).append('canvas')
        .attr('width', gridWidth)
        .attr('height', height)

      context = canvas.node().getContext '2d'
      scaleForRetina canvas, context
      path.context(context)

      extent = d3.extent blockgroups.features, (d) ->
        mapping.value.call this, d.properties
      fill.domain extent

      # Draw the blockgroups
      for blockgroup in blockgroups.features
        val = mapping.value.call(this, blockgroup.properties)

        context.beginPath()
        context.fillStyle = fill(val)
        context.strokeStyle = 'rgba(255, 255, 255, 0.2)'
        context.lineWidth = 0.2
        path(blockgroup)
        context.fill()
        context.stroke()

      # Draw the bodies of water
      context.beginPath()
      path(water)
      context.fillStyle = '#151515'
      context.fill()

      # Draw the bodies of water
      context.beginPath()
      path(parks)
      context.fillStyle = '#151515'
      context.fill()

      legend = d3.select(this).append('ol')
        .attr('class', 'legend')
        .style('width', "#{gridWidth}px")

      quantiles = fill.quantiles()

      legend.selectAll('.value')
        .data(quantiles)
      .enter().append('li')
        .attr('class', 'value')
        .style('background', (d, i) -> colors[i + 1])
      .append('span')
        .text((d, i) ->
          v = formatSymbol Math.round(d)
          if i == 0 then "<#{v}"
          else if i == quantiles.length - 1 then "#{v}+"
          else v)
        .style('visibility', (d, i) ->
          if i % 3 and i != quantiles.length - 1 then 'hidden'
        )

formatSymbol = (number) ->
  return number if number < 1e+3
  pf = d3.formatPrefix(number)
  "#{pf.scale(number).toFixed(1)}#{pf.symbol}"

# Fix for blurry canvas elements on Retina MBP
scaleForRetina = (canvas, context) ->
  width = $(canvas.node()).width()
  height = $(canvas.node()).width()

  devicePixelRatio = window.devicePixelRatio || 1
  backingStoreRatio = context.webkitBackingStorePixelRatio ||
                      context.mozBackingStorePixelRatio ||
                      context.msBackingStorePixelRatio ||
                      context.oBackingStorePixelRatio ||
                      context.backingStorePixelRatio || 1

  ratio = devicePixelRatio / backingStoreRatio

  if window.devicePixelRatio != backingStoreRatio
    canvas
      .attr('width', width * ratio)
      .attr('height', height * ratio)
      .style('width', width + 'px')
      .style('height', height + 'px')

    context.scale(ratio, ratio)

$(render)