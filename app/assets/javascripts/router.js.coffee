EmberBlog.Router.map ()->
  this.route 'index',
    path: '/'

  this.resource 'users'

  this.resource 'posts', ->
    this.resource 'comments'
    this.route 'new'

  this.resource 'post',
    path: '/posts/:post_id'
  , ->
    this.route 'edit'
    this.route 'delete'  