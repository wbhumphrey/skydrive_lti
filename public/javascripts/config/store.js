// by default, persist application data to localStorage.
require('../vendor/localstorage_adapter');

module.exports = DS.Store.extend({
//  revision: 11,
//  adapter: DS.LSAdapter.create()
  adapter: DS.RESTAdapter.create()
});

