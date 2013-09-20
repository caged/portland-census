# Map human readable labels to fields in the CSV files.
#
#  KEY: [2000, 2010, colors]
#
# If an array is given for a year, all values will be summed together to get
# a resulting value
#

window.__mappings =
  # Population
  'Total Population':     (d) -> d.b01001e1
  'White Population':     (d) -> d.b02001e2
  'Black Population':     (d) -> d.b02001e3
  'Hispanic Population':  (d) -> d.b03002e12
  'Asian Population':     (d) -> d.b02001e5
  'Other Population':     (d) -> d.b02001e6 + d.b02001e7
  'Percent White':        (d) -> d.b02001e2 / d.b01001e1 * 100
  'Percent Black':        (d) -> d.b02001e3 / d.b01001e1 * 100
  'Percent Hispanic':     (d) -> d.b03002e12 / d.b01001e1 * 100
  'Percent Other':        (d) -> d.b02001e6 + d.b02001e7 / d.b01001e1 * 100

  # Work and culture
  'Bike to Work':         (d) -> d.b08301e18 / d.b08301e1 * 100

  # Economics
  'Living in Poverty':    (d) -> d.b17017e1



