//= require sinon
//= require application

mocha.ui('bdd');
mocha.globals(['Ember', 'DS', 'App', 'MD5']);
mocha.timeout(5);
chai.Assertion.includeStack = true;

ENV = {
  TESTING: true
};

EmberBlog.Router.reopen({
  location: 'none'
});

// Ember.run(function() {
//   EmberBlog.deferReadiness();
// });

window.server = sinon.fakeServer.create();

window.testHelper = {
  lookup: function(object, object_name) {
    name = object_name || "main";
    return EmberBlog.__container__.lookup(object + ":" + name);
  }
}

Konacha.reset = Ember.K;

// beforeEach(function() {
//   Ember.testing = true;

//   Ember.run(function() {
//     EmberBlog.advanceReadiness();

//     EmberBlog.then(function() {
//       done();
//     });
//   });
// });

// afterEach(function() {
//   Ember.run(function() {
//     EmberBlog.reset();
//   });
// });