class AnswerChoice < ActiveRecord::Base
  belongs_to(
    :question,
    :class_name => 'Question',
    :foreign_key => :question_id,
    :primary_key => :id
  )

  has_many(
    :responses,
    :class_name => 'Response',
    :foreign_key => :answerchoice_id,
    :primary_key => :id
  )

  def self.new_answer_choice(question, text)
    AnswerChoice.new(text: text, question_id: question.id)
  end
end
