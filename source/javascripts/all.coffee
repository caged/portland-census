#= require mappings
years  = [2000, 2010]
width  = 900
height = 620
vis    = null
places = null
neighborhoods = null
legend = null
format = d3.format ','
colors = [
  '#ffeca7'
  '#ffdd8c'
  '#ffdd7c'
  '#fba447'
  '#f68736'
  '#f37636'
  '#ca6632'
  '#c0513f'
  '#a2503a'
  '#793738'
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
      <th>Change</th>
      <th>% Change</th>
    </tr>
    <tr>
      <td>#{format d.data[0]}</td>
      <td>#{format d.data[1]}</td>
      <td>#{format d.data[2]}</td>
      <td>#{d.data[3]}</td>
    </tr>
  </table>
  "

d3.json 'data/neighborhoods.json', (pdx) ->
  neighborhoods = topojson.feature pdx, pdx.objects.neighborhoods

  projection.scale(1).translate [0, 0]

  b = path.bounds(neighborhoods)
  s = .95 / Math.max((b[1][0] - b[0][0]) / width, (b[1][1] - b[0][1]) / height)
  t = [(width - s * (b[1][0] + b[0][0])) / 2, (height - s * (b[1][1] + b[0][1])) / 2]

  projection.scale(s).translate(t)

  loadCensusData(mapDataToNeighborhoods)

  vis.append('pattern')
    .attr('id', 'hatch')
    .attr('patternUnits', 'userSpaceOnUse')
    .attr('width', 4)
    .attr('height', 4)
  .append('path')
    .style('stroke', '#999')
    .style('stroke-width', 0.5)
    .style('shape-rendering', 'crispedges')
    .attr('d', 'M-1,1 l2,-2 M0,4 l4,-4 M3,5 l2,-2')

  vis.selectAll('.neighborhood')
    .data(neighborhoods.features)
  .enter().append('path')
    .attr('class', (d) -> "neighborhood #{d.properties.NAME.toLowerCase().replace(/\s+/, '-')}")
    .classed('unclaimed', (d) -> d.properties.NAME.toLowerCase().indexOf('unclaimed') != -1)
    .classed('shared', (d) -> d.properties.SHARED)
    .attr('d', path)

$ ->
  vis = d3.select('.js-map').append('svg')
    .attr('width', width)
    .attr('height', height)
    .call(tip)

  legend = d3.select '.js-entries'

  menu = d3.select('.js-menu-subject').on 'change', (d) ->
    subject = d3.event.target.value
    type = d3.select('.js-menu-type').node().selectedIndex
    highlight subject, type

  d3.select('.js-menu-type').on 'change', (d) ->
    subjectMenu = d3.select '.js-menu-subject'
    type = d3.event.target.selectedIndex
    subjectIndex = subjectMenu.node().selectedIndex
    subject = d3.select(subjectMenu.node().options[subjectIndex]).attr 'value'
    highlight subject, type

  for key of __mappings
    menu.append('option')
      .attr('value', key)
      .text(key)

# Highlight a specific census category
#
# subject - Name of the census mapping
# type    - Index of type (2000, 2010, total change, % growth)
highlight = (subject, type) ->
  colorRange = __mappings[subject][2] ?= colors
  [min, max] = d3.extent places, (d) -> d.value[subject][type]

  updateInfo subject, type, __mappings[subject]

  intensity.domain([min, max]).range colorRange

  vis.selectAll('.neighborhood:not(.shared):not(.unclaimed)')
    .style 'fill', (d) ->
      name = d.properties.NAME
      place = places.filter((p) -> p.key == name)[0]
      count = place.value[subject][type]
      intensity(count)
    .on('mouseover', (d) ->
      name = d.properties.NAME
      place = places.filter((p) -> p.key == name)[0]
      tip.show name: name, subject: subject, data: place.value[subject])
    .on 'mouseout', tip.hide

# Map topojson neighborhood data to census data mappings specified in mappings.coffee
#
# data - Census topojson data
#
mapDataToNeighborhoods = (data) ->
  nhoods = {}
  for hood in neighborhoods.features
    name = hood.properties.NAME
    shared = hood.properties.SHARED

    if !shared && !shouldExcludeNeighborhood(name)
      current = nhoods[name] = {}
      current[2010] = data[2010].filter((d) -> d.NEIGHBORHOOD == name)[0]
      current[2000] = data[2000].filter((d) -> d.NEIGHBORHOOD == name)[0]

      for key, ids of window.__mappings
        try
          from   = d3.sum(ids[0].map (id) -> current[2000][id])
          to     = d3.sum(ids[1].map (id) -> current[2010][id])
          change = to - from
          growth = parseFloat ((change / from) * 100).toFixed(1)
          growth = 100 if !isFinite growth
          current[key] = [from, to, change, growth]
        catch e
          console.log "ERROR!!!! #{e} #{name} #{key}"

      delete current[2000]
      delete current[2010]

  places = d3.entries(nhoods).filter (nh) -> !shouldExcludeNeighborhood(nh.key)
  highlight 'Total Population', 0

# Load census data csv files
loadCensusData = (callback) ->
  out  = {}
  index = 0
  for year in years
    d3.csv "data/portland-neighborhood-demographics-#{year}.csv", (data) ->
      data.map (row) ->
        for key, val of row
          row[key] = parseFloat val if key isnt 'NEIGHBORHOOD'
        row
      out[years[index]] = data
      callback(out) if index == 1
      index += 1

updateInfo = (subject, type, data) ->
  nhoods = places.map((place) -> name: place.key, value: place.value[subject])
    .sort((a, b) ->
      d3.descending a.value[type], b.value[type]
    )[0..19]
  [min, max] = d3.extent nhoods, (d) -> d.value[type]

  legend.selectAll('.entry').remove()
  legend.selectAll('.entry')
      .data(nhoods, (d) -> d.name)
    .enter().append('tr')
      .html((d, i) ->
        change = d.value[3]
        changeClass = if change < 0 then 'down' else 'up'
        changeClass = null if change is 0
        "<tr>
          <td class='rank'>#{i + 1}.</td>
          <td>#{d.name}</td>
          <td class='val'>#{format(d.value[type])}</td>
          <td class='change #{changeClass}'>#{format(change)}%</td>
        </tr>
      ").attr('class', 'entry')


# Should we exclude a neighoborhood from being highlighted.
# Sometimes we want to draw a neighborhood, but not highlight it with others.
# For example, Portland has a lot of MC Unclaimed areas and overlapping
# neighborhood boundaries.
shouldExcludeNeighborhood = (name) ->
  name.toLowerCase().indexOf('unclaimed') != -1