EmberBlog.PostsController = Ember.ArrayController.extend(EmberBlog.PaginateIt,
  needs: ['currentUser']
  currentUser: Ember.computed.alias('controllers.currentUser')
  resource: 'posts'
)