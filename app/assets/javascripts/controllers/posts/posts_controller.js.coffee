EmberBlog.PostsController = Ember.ArrayController.extend
  needs: ['currentUser']
  currentUser: Ember.computed.alias('controllers.currentUser')