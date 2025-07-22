# Test Bench Run Parallel

Parallel runner for projects that use TestBench.

## Usage

Create a test runner file, e.g. `test/automated.rb`:

```ruby
require_relative 'test_init'

TestBench::Parallel::Run.(
  'test/automated',
  exclude: ['some-exclude-pattern-*']
) or exit(false)
```

Control the number of processes by setting `TEST_BENCH_PARALLEL_PROCSESSES` to e.g. `16`. Default value is `Etc.nprocessors`.

## License

The `test_bench-run-parallel` library is released under the [MIT License](./MIT-License.txt)
