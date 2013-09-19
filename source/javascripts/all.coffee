#= require mappings
years  = [2000, 2010]
width  = 900
height = 680
vis    = null
places = null
neighborhoods = null
directory = null
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
projection  = d3.geo.albers().rotate [120]
path        = d3.geo.path().projection projection

tip = d3.tip().attr('class', 'tip').offset([-3, 0]).html (d) ->
  "<h3>#{d.name} <span>#{d.subject}</span></h3>
  <table>
    <tr>
      <th>2000</th>
      <th>2010</th>
      <th>% Change</th>
      <th>+/-</th>
    </tr>
    <tr>
      <td>#{format d.data[0]}</td>
      <td>#{format d.data[1]}</td>
      <td>#{d.data[3]}</td>
      <td>#{format d.data[2]}</td>
    </tr>
  </table>
  "

d3.json 'data/pdx.json', (pdx) ->
  neighborhoods = topojson.feature pdx, pdx.objects.neighborhoods
  blockgroups = topojson.feature pdx, pdx.objects.pdx

  projection.scale(1).translate [0, 0]

  b = path.bounds(blockgroups)
  s = .99 / Math.max((b[1][0] - b[0][0]) / width, (b[1][1] - b[0][1]) / height)
  t = [(width - s * (b[1][0] + b[0][0])) / 2, (height - s * (b[1][1] + b[0][1])) / 2]

  projection.scale(s).translate(t)

  vis.append('pattern')
    .attr('id', 'hatch')
    .attr('patternUnits', 'userSpaceOnUse')
    .attr('width', 4)
    .attr('height', 4)
  .append('path')
    .style('stroke', '#777')
    .style('stroke-width', 0.5)
    .style('shape-rendering', 'crispedges')
    .attr('d', 'M-1,1 l2,-2 M0,4 l4,-4 M3,5 l2,-2')

  vis.selectAll('.blockgroup')
    .data(blockgroups.features)
  .enter().append('path')
    .attr('class', (d) -> "blockgroup")
    .attr('d', path)

  vis.selectAll('.neighborhood')
    .data(neighborhoods.features)
  .enter().append('path')
    .attr('class', (d) -> "neighborhood #{d.properties.name.toLowerCase().replace(/\s+/, '-')}")
    .classed('unclaimed', (d) -> d.properties.name.toLowerCase().indexOf('unclaimed') != -1)
    .classed('shared', (d) -> d.properties.shared)
    .attr('d', path)

$ ->
  width = $('.js-map').outerWidth()
  vis = d3.select('.js-map').append('svg')
    .attr('width', width)
    .attr('height', height)
    .call(tip)