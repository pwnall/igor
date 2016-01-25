# Benchmarking Docker Overheads

To measure the time overhead of managing Docker containers when analyzing
student homework submissions, we can generate analyses for code submissions with
negligible run times, such that most of the processing time can be attributed to
creating/destroying Docker containers.

## Usage

To run the benchmark against `JOBS` x 10 Docker containers:

```bash
rake db:migrate:reset docker:bm JOBS=3
```

The `docker:bm` task consists of the `docker:build_db` task, followed by the
`docker:benchmark` task.
