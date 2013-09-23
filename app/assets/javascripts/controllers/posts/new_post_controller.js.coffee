EmberBlog.NewPostController = Ember.ObjectController.extend
  needs: ['currentUser']
  currentUser: Ember.computed.alias('controllers.currentUser')
  errors: []

  setStatus: (status)->
    @set('content.status', status)

  setUser: ->
    @set('content.author', @get('currentUser.content'))

  validates: ->
    title = @get 'content.title'
    content = @get 'content.content'
    author = @get 'content.author'

    @setErrors({title: title, content: content, author: author})

    not Em.isEmpty(title) and not Em.isEmpty(content) and not Em.isEmpty(author)

  setErrors: (properties) ->
    @clearErrors()
    @get('errors').pushObject('title') if Em.isEmpty(properties.title)
    @get('errors').pushObject('content') if Em.isEmpty(properties.content)
    @get('errors').pushObject('author') if Em.isEmpty(properties.author)

  clearErrors: ->
    @get('errors').clear()

  isErrored: (->
    not Em.isEmpty(@get('errors'))
  ).property('errors.@each')

  isASingularError: (->
    @get('errors').length == 1
  ).property('errors.@each')

  isClear: (->
    Em.isEmpty(@get('content.title')) and Em.isEmpty(@get('content.content'))
  ).property('content')