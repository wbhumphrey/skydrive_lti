var FilesRoute = Ember.Route.extend({
  setupController: function(controller, model) {
    var skydriveAuthorized = Ember.$.getJSON('/api/v1/skydrive_authorized').then(
      function() {
        console.log("SETUP: PASSED");
        Ember.$.getJSON('/api/v1/files').then(function(data) {
          controller.set('model', data);
        })
        controller.set('authRedirectUrl', null);
      },
      function(jqxhr) {
        console.log("SETUP: FAILED");
        controller.set('model', {});
        controller.set('authRedirectUrl', jqxhr.responseText);
      }
    );
  },

  events: {
    completedAuth: function() {
      var ctrl = this.get('controller');
      var popupWindow = ctrl.get('popupWindow');
      if (popupWindow) {
        popupWindow.close();
      }
      ctrl.set('authRedirectUrl', null);
      ctrl.set('popupWindow', null);
      ctrl.set('model', Ember.$.getJSON('/api/v1/files').then(function(data) { ctrl.set('model', data); }));
    }
  }
});

module.exports = FilesRoute;

