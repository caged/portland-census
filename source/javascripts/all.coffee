#= require mappings

width = 800
height = 800
vis    = null

projection = d3.geo.albers().rotate([120])
path = d3.geo.path().projection(projection)

#d3.json 'data/pdx-topo.json', (pdx) ->
d3.json 'data/neighborhoods.json', (pdx) ->
  neighborhoods = topojson.feature pdx, pdx.objects.neighborhoods

  projection.scale(1)
    .translate [0, 0]

  b = path.bounds(neighborhoods)
  s = .95 / Math.max((b[1][0] - b[0][0]) / width, (b[1][1] - b[0][1]) / height)
  t = [(width - s * (b[1][0] + b[0][0])) / 2, (height - s * (b[1][1] + b[0][1])) / 2]

  projection.scale(s)
    .translate t

  names = neighborhoods.features
    .sort((a, b) -> d3.ascending(a.properties.NAME, b.properties.NAME))
    .map (nh) -> nh.properties.NAME

  loadCensusData (data) ->
    nhoods = {}
    for hood in neighborhoods.features
      name = hood.properties.NAME
      shared = hood.properties.SHARED

      if !shared?
        current = nhoods[name] = {}
        current[2010] = data[2010].filter((d) -> d.NEIGHBORHOOD == name)[0]
        current[2000] = data[2000].filter((d) -> d.NEIGHBORHOOD == name)[0]

        for key, ids of window.__mappings
          try
            from = d3.sum(ids[0].map (id) -> current[2000][id])
            to   = d3.sum(ids[1].map (id) -> current[2010][id])
            change = to - from
            growth = parseFloat ((change / from) * 100).toFixed(2)
            current[key] = [from, to, change, growth]
          catch e
            console.log "ERROR!!!! #{e} #{name} #{key}"
        delete current[2000]
        delete current[2010]

    console.log nhoods
  vis.append('pattern')
    .attr('id', 'hatch')
    .attr('patternUnits', 'userSpaceOnUse')
    .attr('width', 4)
    .attr('height', 4)
  .append('path')
    .style('stroke', '#e1e1e1')
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
  vis = d3.select(document.body).append('svg')
    .attr('width', width)
    .attr('height', height)

loadCensusData = (callback) ->
  out  = {}
  years  = [2000, 2010]
  index = -1
  for year in years
    d3.csv "data/portland-neighborhood-demographics-#{year}.csv", (data) ->
      index += 1
      data.map (row) ->
        for key, val of row
          row[key] = parseFloat val if key isnt 'NEIGHBORHOOD'
        row
      out[years[index]] = data
      callback(out) if index == 1