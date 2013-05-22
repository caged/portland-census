#= require mappings

width = 1200
height = 1000
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
        current.mappings = {}

        for key, ids of window.__mappings
          vals2000 = []
          vals2010 = []
          try
            vals2000 = d3.sum ids[0].map (id) -> current[2000][id]
          catch e
            console.log "ERROR!!!! #{e}"
            console.log name, key, vals2000

          # for yeargroup in ids
          #   console.log "#{key} #{i}"

          # current.mappings[key] = [
          #   d3.sum current[2000]
          # ]

          # <pattern id="diagonalHatch" patternUnits="userSpaceOnUse" width="4" height="4">
          #   <path d="M-1,1 l2,-2
          #            M0,4 l4,-4
          #            M3,5 l2,-2" />
          # </pattern>

  vis.append('defs').append('pattern')
    .attr('id', 'hatch')
    .attr('patternUnits', 'userSpaceOnUse')
    .attr('width', 4)
    .attr('height', 4)
  .append('path')
    .style('stroke', '#e1e1e1')
    .style('stroke-width', 0.5)
    .style('shape-rendering', 'crispedges')
    .attr('d', 'M-1,1 l2,-2
                M0,4 l4,-4
                M3,5 l2,-2')

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