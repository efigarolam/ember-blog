EmberBlog.Adapter = DS.RESTAdapter.extend({})

EmberBlog.Store = DS.Store.extend
  adapter: EmberBlog.Adapter