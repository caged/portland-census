# Map human readable labels to fields in the CSV files.
#
#  KEY: [2000, 2010, colors]
#
# If an array is given for a year, all values will be summed together to get
# a resulting value
#
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

window.__mappings =
  'Total Population': [['P001001'], ['P0010001'], colors]
  'White Population': [['P01000310'], ['P007000310'], colors]
  'Black Population': [['P01000411'], ['P007000411'], colors]
  'Hispanic Population': [['P008011', 'P008012', 'P008013', 'P008014', 'P008015', 'P008016', 'P008017'], ['P0050011', 'P0050012', 'P0050013', 'P0050014', 'P0050015', 'P0050016', 'P0050017'], colors]
  'Asian Population': [['P01000613'], ['P007000613'], colors]
  'Total Housing Units': [['H001001'], ['H0010001'], colors]
  'Occupied Housing Units': [['H004002', 'H004003'], ['H0040002', 'H0040003', 'H0040004'], colors]
  'Vacant Housing Units': [['H005002', 'H005003', 'H005004', 'H005005', 'H005006', 'H005007'], ['H0050002', 'H0050004', 'H0050005', 'H0050006', 'H0050007', 'H0050008'], colors]