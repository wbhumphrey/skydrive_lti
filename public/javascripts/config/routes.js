var App = require('./app');

App.Router.map(function() {
  this.route('files', { path: '/' });
  this.route('launch');
  this.route('oauth', { path: '/oauth/callback' });
});