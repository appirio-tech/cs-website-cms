web:     bundle exec ruby config.ru
worker:  env QUEUE=* bundle exec rake resque:work
streamer: bundle exec rake stream:run