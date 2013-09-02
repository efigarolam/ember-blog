EmberBlog.CurrentUserController = Ember.ObjectController.extend
  isAdmin: (->
    @.get('content.admin')
  ).property('content.admin')
