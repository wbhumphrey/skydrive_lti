var AuthenticatedRoute = require('./authenticated_route');

var FilesRoute = AuthenticatedRoute.extend({
  model: function(params) {
    return params;
  },

  serialize: function(model) {
    return { guid: model.guid };
  },

  setupController: function(controller, model) {
    console.log(model);
    var guid = model.guid;
    var skydriveAuthorized = Ember.$.getJSON('/api/v1/skydrive_authorized').then(
      function() {
        Ember.$.getJSON('/api/v1/files/' + guid).then(function(data) {
          controller.set('model', data);
        })
        controller.set('authRedirectUrl', null);
      },
      function(jqxhr) {
        controller.set('model', {});
        controller.set('authRedirectUrl', jqxhr.responseText);
      }
    );
  },

  events: {
    goToFolder: function(folder) {
      var guid = folder.guid;
      this.transitionTo('files', guid);
    },

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

