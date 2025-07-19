require_relative 'test_init'

TestBench::Run::Parallel.(
  'example/test/automated',
  exclude: ['*_init.rb', 'some-exclude-pattern*']
) or exit(false)
