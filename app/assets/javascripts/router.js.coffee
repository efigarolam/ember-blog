EmberBlog.Router.map ()->
  this.route 'index',
    path: '/'

  this.resource 'posts'

  this.route 'new_post',
    path: '/posts/new'

  this.resource 'post',
    path: '/posts/:post_id'
  , ->
    this.route 'edit'
    this.route 'delete'

  this.resource 'admin', ->