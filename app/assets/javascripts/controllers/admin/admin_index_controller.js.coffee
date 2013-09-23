EmberBlog.AdminIndexController = Ember.ArrayController.extend
  needs: ['currentUser']
  currentUser: Ember.computed.alias('controllers.currentUser')
  showMessage: false
  isErrorMessage: false
  message: ''
