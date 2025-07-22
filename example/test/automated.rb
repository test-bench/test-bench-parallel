require_relative 'test_init'

TestBench::Parallel::Run.(
  'example/test/automated',
  exclude: ['*_init.rb', 'some-exclude-pattern*']
) or exit(false)
