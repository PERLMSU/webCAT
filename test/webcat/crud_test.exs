defmodule WebCAT.CRUDTest do
  use WebCAT.DataCase

  alias WebCAT.CRUD
  alias WebCAT.Feedback.{StudentFeedback, StudentExplanation}

  describe "get/2" do
    test "it works with ids that aren't primary keys" do
      sf = Factory.insert(:student_feedback)
      se = Factory.insert(:student_explanation)

      result = CRUD.get(StudentFeedback, sf.id)
      assert not is_nil(result)

      result = CRUD.get(StudentExplanation, se.id)
      assert not is_nil(result)
    end
  end
end
