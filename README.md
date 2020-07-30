Run `travis-download.sh` to download builds and jobs

Run `extract-errors.rb` to filter failures from jobs. This only works for frontend tests.
Note that it will skip any job that has more than ten failures (ignoring in which browser they occured)
