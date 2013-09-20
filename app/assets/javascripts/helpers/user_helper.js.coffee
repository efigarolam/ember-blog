Ember.Handlebars.registerBoundHelper 'fullName', (user) ->
  user.get('name') + ' ' + user.get('lastName') if user