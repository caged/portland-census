render = ->
  width  = $(document.body).width()
  height = 280
  gridWidth = Math.round(width / 4) - 60
  colors = ['#111', '#333', '#555', '#777', '#999', '#bbb', '#ddd', '#fff']

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

      # Draw the neighborhoods
      # context.beginPath()
      # path(neighborhoods)
      # context.strokeStyle = '#fff'
      # context.lineWidth = 0.3
      # context.stroke()

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

# Fix for blurry canvas elements on Retina MBP
scaleForRetina = (canvas, context) ->
  ratio = window.devicePixelRatio / context.webkitBackingStorePixelRatio
  width = $(canvas.node()).width()
  height = $(canvas.node()).width()

  if window.devicePixelRatio != context.webkitBackingStorePixelRatio
    canvas
      .attr('width', width * ratio)
      .attr('height', height * ratio)
      .style('width', width + 'px')
      .style('height', height + 'px')

    context.scale(ratio, ratio)

$(render)