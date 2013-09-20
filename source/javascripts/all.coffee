#= require mappings
#= require grid
return
width  = 900
height = 680
vis    = null
format = d3.format ','
colors = [
  '#0aafed'
  '#3bbff1'
  '#6ccff4'
  '#9ddff8'
  '#ceeffb'
  '#fff'
]

intensity   = d3.scale.quantile()
projection  = d3.geo.albers()
path        = d3.geo.path().projection projection

tip = d3.tip().attr('class', 'tip').offset([-3, 0]).html (d) ->
  d.properties.b01001e1

d3.json 'data/pdx.json', (pdx) ->
  neighborhoods = topojson.feature pdx, pdx.objects.neighborhoods
  blockgroups   = topojson.feature pdx, pdx.objects.pdx
  water         = topojson.feature pdx, pdx.objects.water

  [min, max] = d3.extent blockgroups.features, (d) -> d.properties.b01001e1

  intensity.domain([min, max]).range colors

  projection.scale(1).translate [0, 0]

  b = path.bounds(blockgroups)
  console.log b
  s = .99 / Math.max((b[1][0] - b[0][0]) / width, (b[1][1] - b[0][1]) / height)
  t = [(width - s * (b[1][0] + b[0][0])) / 2, (height - s * (b[1][1] + b[0][1])) / 2]

  projection.scale(s).translate(t)

  vis.selectAll('.blockgroup')
    .data(blockgroups.features)
  .enter().append('path')
    .attr('class', (d) -> "blockgroup")
    .attr('d', path)
    .style('fill', (d) -> intensity(d.properties.b01001e1)
    )
    .on('mouseover', tip.show)
    .on('mouseout', tip.hide)

  vis.selectAll('.neighborhood')
    .data(neighborhoods.features)
  .enter().append('path')
    .attr('class', (d) -> "neighborhood #{d.properties.name.toLowerCase().replace(/\s+/, '-')}")
    .classed('unclaimed', (d) -> d.properties.name.toLowerCase().indexOf('unclaimed') != -1)
    .classed('shared', (d) -> d.properties.shared)
    .attr('d', path)

  vis.selectAll('.water')
    .data(water.features)
  .enter().append('path')
    .attr('class', (d) -> "water")
    .attr('d', path)

$ ->
  width = $('.js-map').outerWidth()
  vis = d3.select('.js-map').append('svg')
    .attr('width', width)
    .attr('height', height)
    .call(tip)