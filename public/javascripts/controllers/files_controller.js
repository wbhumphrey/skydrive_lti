var FilesController = Ember.ObjectController.extend({
  currentUser: function() {
    return App.AuthManager.get('apiKey.user')
  }.property('App.AuthManager.apiKey'),
});

module.exports = FilesController;

