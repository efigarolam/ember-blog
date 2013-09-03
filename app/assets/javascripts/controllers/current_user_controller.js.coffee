EmberBlog.CurrentUserController = Ember.ObjectController.extend
  isAdmin: (->
    @.get('content.admin')
  ).property('content.admin')

EmberBlog.ObjectController = Ember.ObjectController.extend
  needs: ['currentUser']
  currentUser: Ember.computed.alias('controllers.currentUser')

EmberBlog.ArrayController = Ember.ArrayController.extend
  needs: ['currentUser']
  currentUser: Ember.computed.alias('controllers.currentUser')