var FilesController = Ember.ObjectController.extend({
  authRedirectUrl: null,
  popupWindow: null,
  parentFolder: null,
  isLoading: false,

  currentUser: function() {
    return App.AuthManager.get('apiKey.user');
  }.property('App.AuthManager.apiKey'),

  openAuthPopup: function() {
    var popup = window.open(this.get('authRedirectUrl'), 'auth', 'width=755,height=500');
    this.set('popupWindow', popup);
  },

  attach: function(f) {
    alert("You will now attach this file: " + f.name);
    window.location = '/choose/' + f.id;
  }
});

module.exports = FilesController;

