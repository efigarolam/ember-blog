//= require spec_helper

describe('New Post', function() {
  beforeEach(function() {
    admin = testHelper.lookup('store').createRecord('user')
    admin.set('id', 1);
    admin.set('admin', true);

    currentUserController = testHelper.lookup('controller', 'currentUser');
    currentUserController.set('content', admin);

    Ember.run(function() {
      testHelper.lookup('router').transitionTo('new_post');
    });
  });

  context('creating a post', function() {
    beforeEach(function() {
      $('input[name=title]').val('New test title').change();
      $('textarea[name=content]').val('New test content').change();
    });

    it('calls the method save on the route', function() {
      var mock = sinon.mock(testHelper.lookup('route', 'new_post'));
      mock.expects('save').once();

      $('.btn-success').click();

      mock.verify();
      mock.restore();
    });

    it('sets the status to draft', function() {
      $('.btn-success').click();

      expect(testHelper.lookup('controller', 'newPost').get('content.status')).to.equal('draft');
    });

    it('sets the user', function() {
      $('.btn-success').click();

      expect(testHelper.lookup('controller', 'newPost').get('content.author.id')).to.equal(1);
    });
  });

  context('canceling a post', function() {
    it('shows an confirm dialog if the post is dirty', function() {
      var confirmMock = sinon.mock(window);

      confirmMock.expects('confirm').once().withExactArgs('All your changes will be lost, are you sure?');

      $('input[name=title]').val('New test title').change();
      $('textarea[name=content]').val('New test content').change();

      $('.btn-danger').click();

      confirmMock.verify();
      confirmMock.restore();
    });

    it('redirects if the post is dirty', function() {
      var confirmStub = sinon.stub(window, 'confirm').returns(true);
      var redirectMock = sinon.mock(testHelper.lookup('route', 'new_post'));

      redirectMock.expects('transitionTo').once().withExactArgs('admin.index');

      $('input[name=title]').val('New test title').change();
      $('textarea[name=content]').val('New test content').change();

      $('.btn-danger').click();

      redirectMock.verify();
      redirectMock.restore();
    });

    it('redirects if the post is clean', function() {
      var redirectMock = sinon.mock(testHelper.lookup('route', 'new_post'));

      redirectMock.expects('transitionTo').once().withExactArgs('admin.index');

      $('.btn-danger').click();

      redirectMock.verify();
      redirectMock.restore();
    });
  });

  context('attempting to create a post without all required data', function() {
    beforeEach(function() {
      $('input[name=title]').val('').change();
      $('textarea[name=content]').val('').change();
    });

    it('does not call the save method', function() {
      var mock = sinon.mock(testHelper.lookup('route', 'new_post'));
      mock.expects('save').never();

      $('.btn-success').click();

      mock.verify();
      mock.restore();
    });

    it('shows that title is missing', function() {
      $('textarea[name=content]').val('New test content').change();

      $('.btn-success').click();

      expect($('div.alert ul li:first').text()).to.equal('title');
    });

    it('shows that content is missing', function() {
      $('input[name=title]').val('New test title').change();

      $('.btn-success').click();

      expect($('div.alert ul li:first').text()).to.equal('content');
    });
  });
});