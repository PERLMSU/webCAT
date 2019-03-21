defmodule WebCAT.Feedback.StudentFeedbackTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Feedback.StudentFeedback

  describe "changeset/2" do
    test "behaves as expected" do
      assert StudentFeedback.changeset(
               %StudentFeedback{},
               Factory.params_with_assocs(:student_feedback)
             ).valid?
    end
  end

  describe "by_observation/2" do
    test "behaves as expected" do
      flunk("Test needs to be written")
    end
  end

  describe "add/3" do
    test "behaves as expected" do
      flunk("Test needs to be written")
    end

    test "errors out when any related rows don't exist" do
      flunk("Test needs to be written")
    end
  end
end
