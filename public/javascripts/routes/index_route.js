var IndexRoute = Ember.Route.extend({
  redirect: function() {
    this.transitionTo('files', {guid: 'root'});
  }
});

module.exports = IndexRoute;

