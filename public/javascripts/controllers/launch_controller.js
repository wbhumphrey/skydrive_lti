var LaunchController = Ember.Controller.extend({
  attemptedTransition: null,

  authenticatedObserver: function() {
    if (App.AuthManager.isAuthenticated()) {
      var attemptedTrans = this.get('attemptedTransition');
      if (attemptedTrans) {
        attemptedTrans.retry();
        self.set('attemptedTransition', null);
      } else {
        this.transitionToRoute('files');
      }
    }
  }.observes('App.AuthManager.apiKey.accessToken')
});

module.exports = LaunchController;

