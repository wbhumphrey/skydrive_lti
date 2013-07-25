var LaunchController = Ember.Controller.extend({
  attemptedTransition: null,

  authenticatedObserver: function() {
    console.log("Authenticated? " + App.AuthManager.isAuthenticated());
    if (App.AuthManager.isAuthenticated()) {
      var attemptedTrans = this.get('attemptedTransition');
      if (attemptedTrans) {
        attemptedTrans.retry();
        // self.set('attemptedTransition', null);
        this.transitionToRoute('files');
      } else {
        this.transitionToRoute('files');
      }
    }
  }.observes('App.AuthManager.apiKey.accessToken')
});

module.exports = LaunchController;

