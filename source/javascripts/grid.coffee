render = ->
  width  = $(document.body).width()
  height = 320
  gridWidth = Math.round(width / 4) - 2
  colors = ['#0aafed', '#3bbff1', '#6ccff4', '#9ddff8', '#ceeffb', '#fff']
  fill = d3.scale.quantile().range colors

  items = d3.select('.js-grid').selectAll('.item')
    .data(d3.entries(__mappings))
  .enter().append('div')

  items.append('h3')
    .attr('class', 'title')
    .text((d) -> d.key)

  projection  = d3.geo.albers().scale(1).translate [ 0, 0 ]
  path = d3.geo.path().projection(projection)

  d3.json 'data/pdx.json', (pdx) ->
    neighborhoods = topojson.feature pdx, pdx.objects.neighborhoods
    blockgroups   = topojson.feature pdx, pdx.objects.pdx
    water         = topojson.feature pdx, pdx.objects.water

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
        path(blockgroup)
        context.fill()

      # Draw the neighborhoods
      context.beginPath()
      path(neighborhoods)
      context.strokeStyle = '#fff'
      context.lineWidth = 0.3
      context.stroke()

      # Draw the bodies of water
      context.beginPath()
      path(water)
      context.fillStyle = '#010101'
      context.fill()

# Fix for blurry canvas elements on Retina MBP
scaleForRetina = (canvas, context) ->
  ratio = window.devicePixelRatio / context.webkitBackingStorePixelRatio
  width = $(canvas.node()).outerWidth()
  height = $(canvas.node()).outerHeight()

  if window.devicePixelRatio != context.webkitBackingStorePixelRatio
    canvas
      .attr('width', width * ratio)
      .attr('height', height * ratio)
      .style('width', width + 'px')
      .style('height', height + 'px')

    context.scale(ratio, ratio)

$(render)