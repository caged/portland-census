# Map human readable labels to fields in the CSV files.
#
#  KEY: [2000, 2010]
#
# If an array is given for a year, all values will be summed together to get
# a resulting value
#
window.__mappings =
  'White Population': [['P008003', 'P008011'], ['P0050003', 'P0050011']]
  'Black Population': [['P008004', 'P008012'], ['P0050004', 'P0050012']]