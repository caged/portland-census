# all.coffee
width = 1200
height = 1000
vis    = null

projection = d3.geo.albers().rotate([120])
path = d3.geo.path().projection(projection)

#d3.json 'data/pdx-topo.json', (pdx) ->
d3.json 'data/portland-neighborhoods.json', (pdx) ->
  neighborhoods = topojson.feature pdx, pdx.objects.neighborhoods

  projection.scale(1)
    .translate [0, 0]

  b = path.bounds(neighborhoods)
  s = .95 / Math.max((b[1][0] - b[0][0]) / width, (b[1][1] - b[0][1]) / height)
  t = [(width - s * (b[1][0] + b[0][0])) / 2, (height - s * (b[1][1] + b[0][1])) / 2]

  projection.scale(s)
    .translate t

  vis.selectAll('.neighborhood')
    .data(neighborhoods.features)
  .enter().append('path')
    .attr('class', 'neighborhood')
    .attr('d', path)

$ ->
  vis = d3.select(document.body).append('svg')
    .attr('width', width)
    .attr('height', height)
