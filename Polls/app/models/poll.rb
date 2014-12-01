class Poll < ActiveRecord::Base
  belongs_to(
    :author,
    :class_name => 'User',
    :foreign_key => :author_id,
    :primary_key => :id
  )

  has_many(
    :questions,
    :class_name => 'Question',
    :foreign_key => :poll_id,
    :primary_key => :id
  )

  def self.new_poll(user, title)
    Poll.new(author_id: user.id, title: title)
  end
end
