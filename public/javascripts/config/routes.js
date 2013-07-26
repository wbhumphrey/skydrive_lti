var App = require('./app');

App.Router.map(function() {
  this.route('files', { path: '/:guid' });
  this.route('launch', { path: '/launch/:code' });
  this.route('oauth', { path: '/oauth/callback' });
});