¡Qué onda! Recientemente me encontraba trabajando en una entrada sobre desarrollar aplicaciones web modernas utilizado Rails + Ember.js. Y pues repentinamente sucedió lo que muchos desarrolladores, yo incluído, estaban esperando: Ember.js alcanzó su primera versión final `1.0.0`.

Junto con esta versión final, el equipo de Ember.js liberó Ember Data `1.0.0.-beta`, y si la comparamos con la version anterior `0.13`, tiene un montón de cambios, por lo que actualizar tu vieja aplicación de Ember.js ¡puede ser un pequeño problema!

¿Porqué digo esto?, Pues por que tu aplicación puede dejar de funcionar, y es que como ya probablemente sabes, las aplicaciones hechas con JavaScript tienen la tendencia a romperse con el más ligero cambio.

La intención de ésta entrada es mostrarte los cambios más importantes que encontré mientras realizaba la actualización de mi aplicación de ejemplo. Cabe destacar que los mayores cambios provienen de Ember Data.

## Modelos.

Uno de los cambios más interesantes sobre los Modelos es la forma en que se declaran las relaciones entre objectos. Con Ember Data 0.13 tenías:

    App.Post = DS.Model.extend
      title: DS.attr('string')
      content: DS.attr('string')
      author: DS.belongsTo('App.User')
      comments: DS.hasMany('App.Comment')

Ahora tienes que escribirlo de está manera:

    App.Post = DS.Model.extend
      title: DS.attr('string')
      content: DS.attr('string')
      author: DS.belongsTo('user')
      comments: DS.hasMany('comment')

Como puedes ver, ahora no tienes que especificar completamente el nombre del objeto, también es en minúsculas. En el caso de que tengas un Modelo compuesto por 2 palabras, la relación debe ser declarada en `camel case` Por ejemplo: `App.UsersGroup` debe ser `DS.hasMany('usersGroup')`.

## Adaptadores &amp; Serializadores.

Este cambio afecta también a los Modelos. Si has usado Ember.js con Rails antes, recordarás que las propiedades del JSON eran normalizadas automáticamente, de `last_name` a `lastName` por ejemplo. Ahora, ese comportamiento fue removidode Ember Data 1.0.0-beta. Pero no te preoucpes, el equipo de Ember Data está trabajando en un adaptador especial para Rails: el `ActiveModelAdapter` que incluirá el comportamiento de la versión previa. Mientras esto pasa, puedes cambiar tus modelos a algo como esto:

    App.User = DS.Model.extend
      name: DS.attr('string')
      last_name: DS.attr('string')
      email: DS.attr('string')

Eventualmente, tendrás acceso a las propiedades de la misma manera: `fullName = user.get('name') + ' ' + user.get('last_name')`. Eso no representa ningún problema ¿cierto?. Con esto te ahorrarás una tarea de normalización y serialización, pues los atributos serán mandados al servidor tal y como se declararon en el Modelo de Ember.js, recuerda que Rails acepta los parámetros en `snake case`, como: `last_name`.

Otro cambio importante sobre los Adaptadores y Serializadores es que ahora ellos estan conectados por el nombre, es decir, existe una convención, el `Convention over Configuration` de Rails, también se presenta en Ember.js. También, no necesitas declarar un `store` y podemos tener un Adaptador/Serializador por Modelo. Por ejemplo, con Ember Data 0.13 teníamos:

    App.Post = DS.Model.extend({
      # aquí van las propiedades
    })

    App.PostSerializer = DS.RESTSerializer.extend({
      # comportamiento personalizado
    })

    App.PostAdapter = DS.RESTAdapter.extend
      serializer: 'App.PostSerializer'

    App.Store = DS.Store.extend()

    App.Store.registerAdapter App.Post, App.PostAdapter

Pero ahora con la nueva versión de Ember Data, solo necesitamos declarar lo siguiente:

    App.Post = DS.Model.extend({
      # aquí van las propiedades
    })

    App.PostSerializer = DS.RESTSerializer.extend({
      # comportamiento personalizado
    })

    App.PostAdapter = DS.RESTAdapter.extend({
      # comportamiento personalizado
    })

Como te lo dije antes, declarar el `store` ya no es necesario y tampoco que tenemos que especificar el Serializador dentro del Adaptador, ¡esto es la "convención sobre configuración" trabajando!

Finalmente, hay algunos cambios en el JSON que nuestro servidor debe regresar, dichos cambios se encuentran principalmente en las propiedades de relación, así que en lugar de esto:

    {
      "users": [
        {
        "id": 1,
        "name": "Eduardo",
        "last_name": "Figarola Mota",
        "email": "eduardo.figarola@crowdint.com"
        }
      ],
      "comments": [
        {
          "id": 1,
          "content": "Very interesting...",
          "user_id": 2,
          "post_id": 1
        },
        {
          "id": 2,
          "content": "Nice work!",
          "user_id": 3,
          "post_id": 1
        }
      ],
      "post": {
        "id": 1,
        "title": "Hello World!",
        "content": "Building a cutting-edge web application...",
        "author_id": 1,
        "comment_ids": ["1","2"]
      }
    }

Tu servidor deberá regresar algo como esto:

    {
      "users": [
        {
        "id": 1,
        "name": "Eduardo",
        "last_name": "Figarola Mota",
        "email": "eduardo.figarola@crowdint.com"
        }
      ],
      "comments": [
        {
          "id": 1,
          "content": "Very interesting...",
          "user": 2,
          "post": 1
        },
        {
          "id": 2,
          "content": "Nice work!",
          "user": 3,
          "post": 1
        }
      ],
      "post": {
        "id": 1,
        "title": "Hello World!",
        "content": "Building a cutting-edge web application...",
        "author": 1,
        "comments": ["1","2"]
      }
    }

Como puedes ver, ya no hay `_id` o `_ids` en las propiedades de asociación. Y esto puede ser logrado con el siguiente ActiveModelSerializer en Rails:

    class PostSerializer < ActiveModel::Serializer
      attributes :id, :title, :content
      embed :ids, include: true

      has_one :author, key: :author, root: :users
      has_many :comments, key: :comments, root: :comments
    end

## Obteniendo datos del servidor:

Este cambio es uno de los que más me gustó. Finalmente podemos saber cuando la información está completamente cargada en nuestra aplicación. Y eso es gracias a que los `finders` ahora regresan "promesas". Las promesas, de acuerdo a Martin Fowler, "son objetos que representan el resultado pendiente de una operación asíncrona. Se pueden usar para agendar actividad posterior a la finalización de la operación asíncrona, mediante un callback". En resumen, ahora tenemos callbacks.

Primeramente, veamos el nuevo código para cargar Modelos en nuestras Rutas, en Ember Data 0.13 teníamos:

    App.UsersRoute = Ember.Route.extend
      model: ->
        App.User.find()

O algo como esto:

    App.UserRoute = Ember.Route.extend
      model: (params) ->
        App.User.find(params.id)

Ahora con Ember Data 1.0.0-beta, el código para hacer esto es:

    App.UsersRoute = Ember.Route.extend
      model: ->
        @store.find('user')

y:

    App.UserRoute = Ember.Route.extend
      model: (params) ->
        @store.find('user', params.id)

La manera en que creamos nuevos registros ha cambiado también, comparemos entre versiones, en Ember Data 0.13 teníamos:

    App.NewUserRoute = Ember.Route.extend
      model: ->
        App.User.createRecord()

      actions:
        save: ->
          @controllerFor('newUser').get('transaction').commit()


Ember Data 1.0.0-beta ahora trabaja de esta forma:

    App.NewUserRoute = Ember.Route.extend
      model: ->
        @store.createRecord('user')

      actions:
        save: ->
          @modelFor('newUser').save()

Finalmente, veamos un ejemplo de una Promesa, observa el siguiente código, correspondiente a Ember Data 0.13:

    someMethod: ->
      post = App.Post.find(1)

      # Si el servidor se tarda un poco obteniendo el post
      # el console.log pondrá "null" por
      # el método find es una operación asíncrona.
      console.log post.get('title')

Pero con Ember Data 1.0.0-beta y el concepto de "Promesas", ya no nos tenemos que preocupar por eso:

    someMethod: ->
      @store.find('post', 1).then (post) ->
        console.log post.get('title')

Ahora todo es posible gracias al callback `then` ¿y adivina qué? El método `save` también nos provee una promesa!

    App.NewUserRoute = Ember.Route.extend
      model: ->
        @store.createRecord('user')

      actions:
        save: ->
          @modelFor('newUser').save().then ->
            # Modelo guardado correctamente
            @transitionTo('users');
          , ->
            # Algo fallo guardando el Modelo
            alert 'Something went wrong'

## Controllers.

Con la nueva versión de Ember.js, los métodos en el controllador están 'obsoletos'. Ellos recomiendan que pongas todos tus métodos dentro de un objeto llamado `actions`, como esto:

    App.MyController = Ember.ObjectController.extend
      actions:
        method1: ->
          # haz algo
        method2: ->
          # haz otra cosa

## Actualizando Ember.js desde una aplicación de Rails.

Si estás usando Ember.js junto con Rails, probablemente estés usando la gema `ember-rails`. Si quieres probar todo lo que he mencionado previamente, puedes ejecutar el siguiente comando desde la consola:

    bundle exec rails generate ember:install --head

Esto descargará las últimas 'builds' de Ember.js y Ember Data. Te recomiendo crear una nueva rama en git para probar todo esto.

## Conclusiones.

El equipo de Ember.js ha realizado un gran esfuerzo para mejorar el framework, estos nuevos cambios son fáciles de comprender y algunos de ellos eran esperados desde hace un buen tiempo. Espero que hayas disfrutado la lectura. No tengo dudas de que vendrán más cambios.

Si estas interesado en aprender como desarrollar una aplicación de Rails + Ember.js desde cero, entonces espera un poco, estoy trabajando en los detalles finales de un tutorial sobre eso.

Nos vemos la próxima vez.

## Fuentes.

- [Ember.js blog](http://emberjs.com/blog/)
- [Discuss Ember.js](http://discuss.emberjs.com/)
- [Ember.js Repo](https://github.com/emberjs/ember.js)
- [Ember Data Repo](https://github.com/emberjs/data)
- [Transition document](https://github.com/emberjs/data/blob/master/TRANSITION.md)
