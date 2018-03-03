web: bundle exec rails server -p $PORT -b 0.0.0.0
queue: env TERM_CHILD=1 QUEUE=* bundle exec rake resque:work
mailcatcher: env mailcatcher -f --http-ip 0.0.0.0
