class User < ActiveRecord::Base
  validates :user_name, :uniqueness => true, :presence => true

  has_many(
    :authored_polls,
    :class_name => 'Poll',
    :foreign_key => :author_id,
    :primary_key => :id
  )

  has_many(
    :responses,
    :class_name => 'Response',
    :foreign_key => :user_id,
    :primary_key => :id
  )

  def self.new_user(user_name)
    raise "error then stop" if user_name.class != String
    User.new(user_name: user_name)
  end

  def completed_polls
    sql = <<-SQL
       LEFT OUTER JOIN
       (
         SELECT
           responses.*
         FROM
          responses
        WHERE
           responses.user_id = #{self.id}
       ) AS user_responses
       ON answer_choices.id = user_responses.answerchoice_id
    SQL

    Poll.joins(:questions => :answer_choices)
    .joins(sql)
    .group("polls.id")
    .having("COUNT(DISTINCT questions.*) = COUNT(user_responses.id)")
  end

  # User.find_by_sql([<<-SQL, 0])
  # SELECT
  #   polls.*, COUNT(DISTINCT questions.*) AS question_count
  # FROM
  #   polls
  # JOIN
  #   questions ON poll.id = questions.poll_id
  # JOIN
  #   answer_choices ON answer_choices.question_id = questions.id
  # LEFT OUTER JOIN
  #   (
  #     SELECT
  #       responses.*
  #     FROM
  #       responses
  #     WHERE
  #       responses.user_id = ?
  #   ) AS user_responses
  #   ON user_responses.answerchoice_id = answer_choices.id
  # GROUP BY
  #   polls.id
  # HAVING COUNT(DISTINCT questions.*) = COUNT(responses.id)
  # SQL

end
