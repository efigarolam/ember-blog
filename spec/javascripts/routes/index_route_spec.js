//= require spec_helper

describe('Index Route', function() {
  it('calls the method redirect', function() {
    var mock = sinon.mock(testHelper.lookup('route', 'index'));
    mock.expects('transitionTo').once().withExactArgs('posts');

    Ember.run(function() {
      testHelper.lookup('router').transitionTo('index');
    });

    mock.verify();
    mock.restore();
  });
});