Ember.Handlebars.registerBoundHelper 'fullName', (user) ->
  user.get('name') + ' ' + user.get('last_name')