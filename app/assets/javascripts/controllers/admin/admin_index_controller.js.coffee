EmberBlog.AdminIndexController = Ember.ArrayController.extend(EmberBlog.PaginateIt,
  needs: ['currentUser']
  currentUser: Ember.computed.alias('controllers.currentUser')
  showMessage: false
  isErrorMessage: false
  message: ''
  resource: 'posts'
)