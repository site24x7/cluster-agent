bind = '0.0.0.0:5000'
backlog = 100
workers = 2
threads = 2
timeout = 30
worker_class = 'gevent'
worker_connections = 1000

# gunicorn pid's
pidfile = '/home/site24x7/monagent/conf/gunicorn_pid_file'

# logging
errorlog = '/home/site24x7/monagent/logs/details/stderr.txt'
loglevel = 'info'


def post_fork(server, worker):
    server.log.info("Worker spawned (pid: %s)", worker.pid)


def pre_fork(server, worker):
    server.log.info("Worker spawned (pid: %s)", worker.pid)


def pre_exec(server):
    server.log.info("Forked child, re-executing.")


def when_ready(server):
    server.log.info("Server is ready. Spawning workers")


def worker_abort(worker):
    worker.log.info("worker received SIGABRT signal")
