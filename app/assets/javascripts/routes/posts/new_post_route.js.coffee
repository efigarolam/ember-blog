EmberBlog.NewPostRoute = Ember.Route.extend
  model: ->
    @store.createRecord('post')

  enter: ->
    @transitionTo('posts') unless @controllerFor('currentUser').get('isAdmin')

  renderTemplate: ->
    @render('posts/new')
    @render 'admin/go_back_button',
      outlet: 'navigation'

  save: ->
    @modelFor('newPost').save().then ->
      @controllerFor('newPost').clearErrors()
      @redirectTo 'admin'
    , ->
      alert "An error has ocurred."

  rollBackAndRedirectTo: (route) ->
    @modelFor('newPost').rollback()
    @redirectTo route

  redirectTo: (route) ->
    @transitionTo route

  actions:
    prepare: ->
      @controllerFor('newPost').setStatus 'draft'
      @controllerFor('newPost').setUser()

      if @controllerFor('newPost').validates()
        @save()

    goBack: ->
      shouldConfirm =  not @controllerFor('newPost').get('isClear')

      if shouldConfirm and confirm 'All your changes will be lost, are you sure?'
        @rollBackAndRedirectTo 'admin'
      else if not shouldConfirm
        @rollBackAndRedirectTo 'admin'

      @controllerFor('newPost').clearErrors()


