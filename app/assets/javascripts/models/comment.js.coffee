EmberBlog.Comment = DS.Model.extend
  user: DS.belongsTo('user')
  post: DS.belongsTo('post')
  content: DS.attr('string')
  status: DS.attr('string')