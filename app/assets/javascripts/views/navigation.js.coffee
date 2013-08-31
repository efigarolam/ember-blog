EmberBlog.Navigation = Ember.View.extend
  templateName: 'navigation'

EmberBlog.NavOptionTab = Ember.View.extend
  tagName: 'li'

  classNameBindings: 'isActive:active'.w()

  isActive: (->
    routeParts = window.location.hash.split('/').length - 1
    currentPath = window.location.hash.split('/')[routeParts]
    @.get('option') is currentPath
  ).property('option')
