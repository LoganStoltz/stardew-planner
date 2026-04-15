bind "tcp://0.0.0.0:4567"

environment "production"

workers 0
threads 1, 5

preload_app!
