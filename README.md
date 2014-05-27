# Setup

Run the following commands to install all the dependencies, setup the database, insert the seeds, start the solr service and index all the seed data:

    bundle install
    bundle exec rake db:setup
    bundle exec rake sunspot:solr:start
    bundle exec rake sunspot:reindex

# Running specs

Run the following command:

    bundle exec rake konacha:serve

Then go to `http://localhost:3500` and see the specs running!
