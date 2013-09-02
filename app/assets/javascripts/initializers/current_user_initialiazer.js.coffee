EmberBlog.initializer
  name: 'currentUser'

  initialize: (container)->
    currentUserData = $('meta[name=current-user]').attr('content')

    if currentUserData
      object = JSON.parse currentUserData
      store = container.lookup('store:main')

      store.load EmberBlog.User, object
      currentUser = EmberBlog.User.find(object.id)

      container.lookup('controller:currentUser').set('content', currentUser)

      container.typeInjection('controller', 'currentUser', 'controller:currentUser')



