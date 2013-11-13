//= require spec_helper

describe('New Post Route', function() {
  context('when normal user is logged in', function() {
    beforeEach(function() {
      user = testHelper.lookup('store').createRecord('user')
      user.set('admin', false);

      currentUserController = testHelper.lookup('controller', 'currentUser');
      currentUserController.set('content', user);
    });

    it('redirects to all posts', function() {
      var mock = sinon.mock(testHelper.lookup('route', 'new_post'));
      mock.expects('transitionTo').once().withExactArgs('posts');

      Ember.run(function() {
        testHelper.lookup('router').transitionTo('new_post');
      });

      mock.verify();
      mock.restore();
    });
  });

  context('when admin is logged in', function() {
    beforeEach(function() {
      admin = testHelper.lookup('store').createRecord('user')
      admin.set('admin', true);
      currentUserController = testHelper.lookup('controller', 'currentUser');
      currentUserController.set('content', admin);
    });

    it('does not redirect', function() {
      var mock = sinon.mock(testHelper.lookup('route', 'new_post'));
      mock.expects('transitionTo').never();

      Ember.run(function() {
        testHelper.lookup('router').transitionTo('new_post');
      });

      mock.verify();
      mock.restore();
    });
  });
});