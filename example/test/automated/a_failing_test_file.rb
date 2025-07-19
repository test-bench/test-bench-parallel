require_relative 'automated_init'

context "A Failing Test File" do
  comment "Sleep 200ms"
  sleep 0.2

  test "Some failing test" do
    refute(true)
  end
end
