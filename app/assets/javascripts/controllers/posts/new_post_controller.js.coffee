EmberBlog.NewPostController = EmberBlog.ObjectController.extend
  savePost: ->
    @.set('content.author_id', @.get('currentUser.content.id'))

    if @.validates()
      @.get('model').save()
    else
      @.set('error', true)

  validates: ->
    title = @.get 'content.title'
    content = @.get 'content.content'

    not Em.isEmpty(title) and not Em.isEmpty(content)