class Question < ActiveRecord::Base
  has_many(
    :answer_choices,
    :class_name => 'AnswerChoice',
    :foreign_key => :question_id,
    :primary_key => :id
  )

  belongs_to(
    :poll,
    :class_name => 'Poll',
    :foreign_key => :poll_id,
    :primary_key => :id
  )

  has_many :responses, :through => :answer_choices, :source => :responses

  def self.new_question(poll, text)
    Question.new(text: text, poll_id: poll.id)
  end

  def results
    # result_question = {}
    # choices = self.answer_choices.includes(:responses)
    #
    # choices.each do |choice|
    #   result_question[choice.text] = choice.responses.length
    # end
    # result_question
    result_question = {}
    result_arr = self.answer_choices.select("answer_choices.*, COUNT(responses.*) AS response_count")
    .joins("LEFT OUTER JOIN responses ON answer_choices.id = responses.answerchoice_id")
    .where("answer_choices.question_id = ?", self.id)
    .group("answer_choices.id")

    result_arr.each do |result|
      result_question[result.text] = result.response_count
    end

    result_question
  end

  # AnswerChoice.find_by_sql([<<-SQL, 2])
  # SELECT
  #   answer_choices.*, COUNT(responses.*) AS response_count
  # FROM
  #   answer_choices
  # LEFT OUTER JOIN
  #   responses ON answer_choices.id = responses.answerchoice_id
  # WHERE
  #   answer_choices.question_id = ?
  # GROUP BY
  #   answer_choices.id
  # SQL



end
