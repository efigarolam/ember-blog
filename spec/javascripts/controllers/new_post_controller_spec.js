//= require spec_helper

describe('New Post Controller', function() {
  beforeEach(function() {
    newPostController = testHelper.lookup('controller', 'newPost');

    newPostController.set('content', testHelper.lookup('store').createRecord('post'));
    author = testHelper.lookup('store').createRecord('user');
  });

  describe('#validates', function() {
    it('is valid with all required fields', function() {
      newPostController.set('content.title', 'Title test');
      newPostController.set('content.content', 'Content test');
      newPostController.set('content.author', author);

      expect(newPostController.validates()).to.equal(true);
    });

    it('is invalid if title is missing', function() {
      newPostController.set('content.content', 'Content test');
      newPostController.set('content.author', author);

      expect(newPostController.validates()).to.equal(false);
    });

    it('is invalid if content is missing', function() {
      newPostController.set('content.title', 'Title test');
      newPostController.set('content.author', author);

      expect(newPostController.validates()).to.equal(false);
    });

    it('is invalid if author is missing', function() {
      newPostController.set('content.content', 'Content test');
      newPostController.set('content.title', 'Title test');

      expect(newPostController.validates()).to.equal(false);
    });
  });

  describe('#clearErrors', function() {
    it('clears the errors property', function() {
      newPostController.set('errors', ['title', 'content']);
      newPostController.clearErrors();

      expect(newPostController.get('errors').length).to.equal(0);
    });
  });

  describe('#setErrors', function() {
    it('populates the errors property', function() {
      newPostController.setErrors({title: '', content: '', author: null});

      expect(newPostController.get('errors').length).to.equal(3);
    });

    it('does not populates the errors property', function() {
      newPostController.setErrors({title: 'Test', content: 'Test', author: author});

      expect(newPostController.get('errors').length).to.equal(0);
    });
  });
});