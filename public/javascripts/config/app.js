// require other, dependencies here, ie:
// require('./vendor/moment');

require('../vendor/jquery');
require('../vendor/jquery.cookie');
require('../vendor/handlebars');
require('../vendor/ember');
//require('../vendor/ember-data-latest');
require('../vendor/ember-model-latest');
require('../vendor/purl');

var App = window.App = Ember.Application.create();
//App.Store = require('./store'); // delete if you don't want ember-data

module.exports = App;

