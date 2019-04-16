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
end
