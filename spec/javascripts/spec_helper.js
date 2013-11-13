//= require sinon
//= require application

mocha.ui('bdd');
mocha.globals(['Ember', 'DS', 'EmberBlog', 'MD5']);
mocha.timeout(5);
chai.Assertion.includeStack = true;

ENV = {
  TESTING: true
};

window.server = sinon.fakeServer.create();

window.testHelper = {
  lookup: function(object, object_name) {
    name = object_name || "main";
    return EmberBlog.__container__.lookup(object + ":" + name);
  }
}

EmberBlog.Router.reopen({
  location: 'none'
});

Konacha.reset = Ember.K;