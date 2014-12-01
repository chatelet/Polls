class Response < ActiveRecord::Base
  validate :respondent_has_not_already_answered_question
  validate :not_own_poll

  belongs_to(
    :answer_choice,
    :class_name => 'AnswerChoice',
    :foreign_key => :answerchoice_id,
    :primary_key => :id
  )

  belongs_to(
    :respondent,
    :class_name => 'User',
    :foreign_key => :user_id,
    :primary_key => :id
  )

  has_one :question, :through => :answer_choice, :source => :question
  # has_one :to_poll, :through => :to_question, :source => :poll
  # has_one :to_author, :through => :to_poll, :source => :author

  def self.new_response(user, answer_choice)
    Response.new(user_id: user.id, answerchoice_id: answer_choice.id)
  end

  def not_own_poll
    poll_result =
      Poll
      .joins(:questions => {:answer_choices => :responses})
      .where("author_id = ?", self.respondent.id)

    unless poll_result.empty?
      errors[:base] <<  "You can't answer your own poll"
    end


    # if self.question.poll.author.id == self.respondent.id
    #   errors[:base] << "You can't answer your own poll"
    # end
  end

  def sibling_responses
    #self.question.responses.where("? IS NULL OR responses.id != ?", self.id, self.id)
     #calls same responses to question, possibly by different users

     Response
     .joins(:answer_choice => :question)
     .where("? IS NULL OR (questions.id = ? AND responses.id != ?)", self.id, self.question.id, self.id)
  end

  def respondent_has_not_already_answered_question
    errors[:user_id] << "User already answered question" if sibling_responses.exists?(:user_id => self.user_id)
  end

  # select poll.author_id
  # from response
  # join
  #   answer_choice on answer_choice.id = response.answerchoice_id
  # join
  #   questions on questions.id = answer_choice.question_id
  # join
  #   poll on poll.id = question.poll_id
  # where poll.author_id = self.respondent.id

  # select response.*
  # from response
  # join answer_choices AS ac1 on answer_choices.id = response.answerchoice_id
  # join questions AS qlabel on questions.id = answer_choice.question_id
  # # join answer_choices AS ac2 on answer_choices.question_id = question.id
  # # join response AS parameter_taker on answer_choices.id = response.answerchoice_id
  # where
  #    self.id IS NULL OR (response.question_id = self.question.id AND response.id != self.id)

  # SELECT
  #   question_id
  # FROM
  # response
  # join answer_choices AS ac1 on answer_choices.id = response.answerchoice_id
  # join questions AS qlabel on questions.id = answer_choice.question_id
  # WHERE
  # response.id = self.id
  #
  # self.question.id

end
