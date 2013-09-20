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
    @modelFor('newPost').save()

  actions:
    prepare: ->
      @controllerFor('newPost').setStatus('draft')
      @controllerFor('newPost').setUser()

      if @controllerFor('newPost').validates()
        @save()

    goBack: ->
      if confirm('All your changes will be lost, are you sure?')
        @modelFor('newPost').rollback()
        @transitionTo('admin')


