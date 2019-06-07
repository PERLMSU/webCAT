module API.Feedback exposing (Category, Feedback, Observation)

import API exposing (Schema)
import API.Classrooms exposing (Classroom, RotationGroup)



-- API Types


type alias Category =
    Schema
        { name : String
        , description : Maybe String

        -- Foreign keys
        , parent_category_id : Maybe Int
        , classroom_id : Int

        -- Related data
        , parent_category : Maybe Category
        , classroom : Maybe Classroom
        , sub_categories : Maybe (List Category)
        , observations : Maybe (List Observation)
        }


type ObservationType
    = Positive
    | Neutral
    | Negative


type alias Observation =
    Schema
        { content : String
        , type_ : ObservationType

        -- Foreign keys
        , category_id : Int

        -- Related data
        , feedback : Maybe (List Feedback)
        }


type alias Feedback =
    Schema
        { content : String

        -- Foreign keys
        , observation_id : Int

        -- Related data
        , observation : Maybe Observation
        }


type DraftStatus
    = Unreviewed
    | Reviewing
    | NeedsRevision
    | Approved
    | Emailed


type alias Draft =
    Schema
        { content : String
        , status : DraftStatus

        -- Foreign keys
        , userId : Int
        , rotationGroupId : Int

        -- Related data
        , user : Maybe User
        , rotationGroup : Maybe RotationGroup
        , comments : Maybe (List Comment)
        , grades : Maybe (List Grade)
        }


type alias Comment =
    Schema
        { content : String

        -- Foreign keys
        , draftId : Int
        , userId : Int

        -- Related data
        , draft : Maybe Draft
        , user : Maybe User
        }


type alias Grade =
    Schema
        { score : Int
        , note : Maybe String

        -- Foreign keys
        , categoryId : Int
        , draftId : Int

        -- Related data
        , category : Maybe Category
        , draft : Maybe Draft
        }

type alias Email =
    Schema
        { status : String
        -- Foreign keys
        , draftIf : Int
        -- Related data
        , draft : Maybe Draft
        }

type alias StudentFeedback =
    Schema
        { userId : Int
        , rotationGroupId : Int
        , feedbackId : Int

        -- Related data
        , user : Maybe User
        , rotationGroup : Maybe RotationGroup
        , feedback : Maybe Feedback
        }
