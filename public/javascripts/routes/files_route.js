var FilesRoute = Ember.Route.extend({
  model: function() {
    return Ember.$.getJSON('/api/v1/files');
  }
});

module.exports = FilesRoute;

