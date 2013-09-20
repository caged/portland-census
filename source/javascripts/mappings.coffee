# Map human readable labels to fields in the CSV files.
#
#  KEY: [2000, 2010, colors]
#
# If an array is given for a year, all values will be summed together to get
# a resulting value
#

window.__mappings =
  'Total Population':     (d) -> d.b01001e1
  'White Population':     (d) -> d.b02001e2
  'Black Population':     (d) -> d.b02001e3
  'Hispanic Population':  (d) -> d.b03002e1
  'Asian Population':     (d) -> d.b02001e5
  'Other Population':     (d) -> d.b02001e6 + d.b02001e7
