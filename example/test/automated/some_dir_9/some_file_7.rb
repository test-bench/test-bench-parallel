require_relative '../automated_init'

context "Some Context #9" do
  context "Some Inner Context #7" do
    comment "Sleep 200ms"
    sleep 0.2

    test "Some test" do
      assert(true)
    end
  end
end
