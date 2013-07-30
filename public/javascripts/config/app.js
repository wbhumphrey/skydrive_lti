require('../vendor/jquery');
require('../vendor/jquery.cookie');
require('../vendor/handlebars');
require('../vendor/ember');
require('../vendor/ember-model-latest');
require('../vendor/purl');

var App = window.App = Ember.Application.create({ LOG_TRANSITIONS: true });

module.exports = App;

