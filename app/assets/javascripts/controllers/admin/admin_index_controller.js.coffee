EmberBlog.AdminIndexController = Ember.ArrayController.extend(EmberBlog.PaginateIt,
  needs: ['currentUser']
  currentUser: Ember.computed.alias('controllers.currentUser')
  showMessage: false
  isErrorMessage: false
  message: ''

  currentPage: (->
    @get('content.content.firstObject')
  ).property('content.content.firstObject')

  posts: (->
    @get('currentPage.posts')
  ).property('currentPage')
)