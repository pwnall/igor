class RenameAssignmentFeedbacksToSurveys < ActiveRecord::Migration
  def self.up
    rename_table :assignment_feedbacks, :survey_answers
    rename_table :feedback_answers, :survey_question_answers
    rename_table :feedback_questions, :survey_questions
    rename_table :feedback_question_sets, :surveys
    rename_table :feedback_question_set_memberships,
                 :survey_question_memberships
                 
    rename_column :survey_question_answers, :assignment_feedback_id,
                                            :survey_answer_id
    rename_column :survey_question_memberships, :feedback_question_id,
                                                :survey_question_id
    rename_column :survey_question_memberships, :feedback_question_set_id,
                                                :survey_id
    rename_column :assignments, :feedback_question_set_id,
                                :feedback_survey_id
  end

  def self.down
    rename_column :survey_question_answers, :survey_answer_id,
                                            :assignment_feedback_id
    rename_column :survey_question_memberships, :survey_question_id,
                                                :feedback_question_id                  
    rename_column :survey_question_memberships, :survey_id,
                                                :feedback_question_set_id
    rename_column :assignments, :feedback_survey_id, :feedback_question_set_id

    rename_table :survey_answers, :assignment_feedbacks
    rename_table :survey_question_answers, :feedback_answers
    rename_table :survey_questions, :feedback_questions
    rename_table :surveys, :feedback_question_sets
    rename_table :survey_question_memberships,
                 :feedback_question_set_memberships
  end
end
