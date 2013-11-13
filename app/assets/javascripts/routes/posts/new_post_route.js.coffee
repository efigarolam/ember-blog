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
    self = @

    @modelFor('newPost').save().then ->
      self.controllerFor('newPost').clearErrors()
      self.redirectTo 'admin.index'
      Em.run.later ->
        self.controllerFor('admin.index').set('showMessage', true)
        self.controllerFor('admin.index').set('message', 'Yay! the post has been created successfully!')
      , 200
    , ->
      self.controllerFor('admin.index').set('showMessage', true)
      self.controllerFor('admin.index').set('isErrorMessage', true)
      self.controllerFor('admin.index').set('message', 'Oops! something went wrong!')

  rollBackAndRedirectTo: (route) ->
    @modelFor('newPost').rollback()
    @redirectTo route

  redirectTo: (route) ->
    @transitionTo route

  actions:
    prepare: ->
      @modelFor('newPost').set('status', 'draft')
      @modelFor('newPost').set('author',  @controllerFor('currentUser').get('content'))

      if @controllerFor('newPost').validates()
        @save()

    goBack: ->
      shouldConfirm =  not @controllerFor('newPost').get('isClear')

      if shouldConfirm and confirm 'All your changes will be lost, are you sure?'
        @rollBackAndRedirectTo 'admin.index'
      else if not shouldConfirm
        @rollBackAndRedirectTo 'admin.index'

      @controllerFor('newPost').clearErrors()


