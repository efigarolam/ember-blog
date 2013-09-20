EmberBlog.initializer
  name: 'currentUser'

  initialize: (container, application)->
    currentUserData = $('meta[name=current-user]').attr('content')

    if currentUserData
      object = JSON.parse currentUserData
      store = container.lookup('store:main')

      store.find('user', object.id).then (currentUser) ->
        container.lookup('controller:currentUser').set('content', currentUser)