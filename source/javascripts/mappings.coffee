# Map human readable labels to fields in the CSV files.
#
#  KEY: [2000, 2010, colors]
#
# If an array is given for a year, all values will be summed together to get
# a resulting value
#

window.__mappings =
  # Population
  'Total population':         (d) -> d.b01001e1
  'White population':         (d) -> d.b02001e2
  'Black population':         (d) -> d.b02001e3
  'Hispanic population':      (d) -> d.b03002e12
  'Percent white':            (d) -> d.b02001e2 / d.b01001e1 * 100
  'Percent black':            (d) -> d.b02001e3 / d.b01001e1 * 100
  'Percent hispanic':         (d) -> d.b03002e12 / d.b01001e1 * 100

  # Work and culture
  'Percent biking to work':       (d) -> d.b08301e18 / d.b08301e1 * 100
  'Travel hour or more to work':  (d) -> d.b08303e12 + d.b08303e13
  'Two or more vehicles':         (d) -> d.b25044e5 + d.b25044e6 + d.b25044e7 + d.b25044e8

  # Economics
  'Living in poverty':          (d) -> d.b17017e1
  'Median household Income':    (d) -> d.b19013e1
  'Receive public assistance':  (d) -> d.b19057e2
  'Households >= $200k income':  (d) -> d.b19001e17

  # Housing
  'Percentage of vacant housing units': (d) -> d.b25002e3 / d.b25001e1 * 100
  'Family Households': (d) -> d.b11001e2
