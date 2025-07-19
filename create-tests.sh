#!/usr/bin/env bash

for dir_index in `seq 1 10`; do
  dir="example/test/automated/some_dir_$dir_index"
  mkdir -vp "$dir"

  for file_index in `seq 1 10`; do
    path="$dir/some_file_$file_index.rb"

    cat > "$path" <<RUBY
require_relative '../automated_init'

context "Some Context #$dir_index" do
  context "Some Inner Context #$file_index" do
    comment "Sleep 200ms"
    sleep 0.2

    test "Some test" do
      assert(true)
    end
  end
end
RUBY
  done
done
