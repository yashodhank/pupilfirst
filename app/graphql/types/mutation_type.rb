module Types
  class MutationType < Types::BaseObject
    field :create_course, mutation: Mutations::CreateCourse, null: false
    field :update_course, mutation: Mutations::UpdateCourse, null: false
    field :create_school_link, mutation: Mutations::CreateSchoolLink, null: false
    field :destroy_school_link, mutation: Mutations::DestroySchoolLink, null: false
    field :update_school_string, mutation: Mutations::UpdateSchoolString, null: false
    field :undo_submission, mutation: Mutations::UndoSubmission, null: false
    field :create_target, mutation: Mutations::CreateTarget, null: false
    field :create_community, mutation: Mutations::CreateCommunity, null: false
    field :update_community, mutation: Mutations::UpdateCommunity, null: false
    field :create_quiz_submission, mutation: Mutations::CreateQuizSubmission, null: false
    field :auto_verify_submission, mutation: Mutations::AutoVerifySubmission, null: false
    field :create_submission, mutation: Mutations::CreateSubmission, null: false
    field :delete_content_block, mutation: Mutations::DeleteContentBlock, null: false
    field :level_up, mutation: Mutations::LevelUp, null: false
    field :move_content_block, mutation: Mutations::MoveContentBlock, null: false
    field :create_applicant, mutation: Mutations::CreateApplicant, null: false
    field :create_school_admin, mutation: Mutations::CreateSchoolAdmin, null: false
    field :update_school_admin, mutation: Mutations::UpdateSchoolAdmin, null: false
    field :create_course_export, mutation: Mutations::CreateCourseExport, null: false
    field :sort_curriculum_resources, mutation: Mutations::SortCurriculumResources, null: false
    field :create_grading, mutation: Mutations::CreateGrading, null: false
    field :undo_grading, mutation: Mutations::UndoGrading, null: false
    field :create_feedback, mutation: Mutations::CreateFeedback, null: false
    field :update_review_checklist, mutation: Mutations::UpdateReviewChecklist, null: false
    field :delete_school_admin, mutation: Mutations::DeleteSchoolAdmin, null: false
    field :create_coach_note, mutation: Mutations::CreateCoachNote, null: false
    field :dropout_student, mutation: Mutations::DropoutStudent, null: false
    field :create_evaluation_criterion, mutation: Mutations::CreateEvaluationCriterion, null: false
    field :update_evaluation_criterion, mutation: Mutations::UpdateEvaluationCriterion, null: false
    field :update_school, mutation: Mutations::UpdateSchool, null: false
    field :archive_coach_note, mutation: Mutations::ArchiveCoachNote, null: false
    field :create_markdown_content_block, mutation: Mutations::CreateMarkdownContentBlock, null: false
    field :create_embed_content_block, mutation: Mutations::CreateEmbedContentBlock, null: false
    field :update_file_block, mutation: Mutations::UpdateFileContentBlock, null: false
    field :update_markdown_block, mutation: Mutations::UpdateMarkdownContentBlock, null: false
    field :update_image_block, mutation: Mutations::UpdateImageContentBlock, null: false
    field :update_target, mutation: Mutations::UpdateTarget, null: false
    field :create_target_version, mutation: Mutations::CreateTargetVersion, null: false
    field :delete_course_author, mutation: Mutations::DeleteCourseAuthor, null: false
    field :create_course_author, mutation: Mutations::CreateCourseAuthor, null: false
    field :update_course_author, mutation: Mutations::UpdateCourseAuthor, null: false
    field :delete_coach_team_enrollment, mutation: Mutations::DeleteCoachTeamEnrollment, null: false
    field :create_topic, mutation: Mutations::CreateTopic, null: false
    field :update_topic, mutation: Mutations::UpdateTopic, null: false
    field :create_post, mutation: Mutations::CreatePost, null: false
    field :update_post, mutation: Mutations::UpdatePost, null: false
    field :create_post_like, mutation: Mutations::CreatePostLike, null: false
    field :delete_post_like, mutation: Mutations::DeletePostLike, null: false
    field :mark_post_as_solution, mutation: Mutations::MarkPostAsSolution, null: false
    field :archive_post, mutation: Mutations::ArchivePost, null: false
    field :merge_levels, mutation: Mutations::MergeLevels, null: false
  end
end
