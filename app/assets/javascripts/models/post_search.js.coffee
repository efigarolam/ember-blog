EmberBlog.PostSearch = DS.Model.extend(EmberBlog.PaginatedCollection,
  posts: DS.hasMany('post')
)