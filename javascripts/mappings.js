(function() {

  window.__mappings = {
    'Total population': function(d) {
      return d.b01001e1;
    },
    'White population': function(d) {
      return d.b02001e2;
    },
    'Black population': function(d) {
      return d.b02001e3;
    },
    'Hispanic population': function(d) {
      return d.b03002e12;
    },
    'Percent white': function(d) {
      return d.b02001e2 / d.b01001e1 * 100;
    },
    'Percent black': function(d) {
      return d.b02001e3 / d.b01001e1 * 100;
    },
    'Percent hispanic': function(d) {
      return d.b03002e12 / d.b01001e1 * 100;
    },
    'Percent biking to work': function(d) {
      return d.b08301e18 / d.b08301e1 * 100;
    },
    'Travel hour or more to work': function(d) {
      return d.b08303e12 + d.b08303e13;
    },
    'Two or more vehicles': function(d) {
      return d.b25044e5 + d.b25044e6 + d.b25044e7 + d.b25044e8;
    },
    'Living in poverty': function(d) {
      return d.b17017e1;
    },
    'Median household Income': function(d) {
      return d.b19013e1;
    },
    'Receive public assistance': function(d) {
      return d.b19057e2;
    },
    'Households >= $200k income': function(d) {
      return d.b19001e17;
    },
    'Percentage of vacant housing units': function(d) {
      return d.b25002e3 / d.b25001e1 * 100;
    },
    'Family Households': function(d) {
      return d.b11001e2;
    }
  };

}).call(this);
