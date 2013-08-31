Ember.Handlebars.registerBoundHelper 'friendlyDate', (date) ->
  if date
    days = 'Sunday Monday Tuesday Wednesday Thursday Friday Saturday'.w()
    months = 'January February March April May June July August September October November December'.w()
    friendlyDate = []

    friendlyDate.pushObject days[date.getUTCDay()]
    friendlyDate.pushObject months[date.getUTCMonth()]
    friendlyDate.pushObject date.getUTCDate()

    friendlyDate.join(' ')
  else
    '';
