var AuthenticatedRoute = Ember.Route.extend({
  beforeModel: function(transition) {
    if (!App.AuthManager.isAuthenticated()) {
      this.redirectToLaunch(transition);
    }
  },

  // Redirect to the login page and store the current transition so we can
  // run it again after login
  redirectToLaunch: function(transition) {
    var launchController = this.controllerFor('launch');
    launchController.set('attemptedTransition', transition);
    this.transitionTo('launch', 'na');
  },

  events: {
    error: function(reason, transition) {
      this.redirectToLaunch(transition);
    }
  }
});

module.exports = AuthenticatedRoute;