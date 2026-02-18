# frozen_string_literal: true

require "test_helper"

class CommentTest < ActiveSupport::TestCase
  fixtures :all

  # === Validations ===

  test "valid comment" do
    assert_valid comments(:plant_1_comment_1)
  end

  test "requires user" do
    comment = Comment.new(
      commentable: plants(:plant_1),
      body: "Test comment"
    )
    assert_invalid comment, :user
  end

  test "requires body" do
    comment = Comment.new(
      commentable: plants(:plant_1),
      user: users(:marcus)
    )
    assert_invalid comment, :body
  end

  test "requires non-blank body" do
    comment = comments(:plant_1_comment_1)
    comment.body = "   "
    assert_invalid comment, :body
  end

  # === Associations ===

  test "belongs to user" do
    assert_equal users(:sarah), comments(:plant_1_comment_1).user
  end

  test "polymorphic commentable - Plant" do
    comment = comments(:plant_1_comment_1)
    assert_equal "Plant", comment.commentable_type
    assert_equal plants(:plant_1), comment.commentable
  end

  test "polymorphic commentable - Project" do
    comment = comments(:project_comment_1)
    assert_equal "Project", comment.commentable_type
    assert_equal projects(:gmo_zkittlez_hunt), comment.commentable
  end

  test "polymorphic commentable - Observation" do
    comment = comments(:observation_comment)
    assert_equal "Observation", comment.commentable_type
    assert_equal observations(:obs_1_flowering), comment.commentable
  end

  test "polymorphic commentable - Strain" do
    comment = comments(:strain_comment)
    assert_equal "Strain", comment.commentable_type
    assert_equal strains(:gmo_x_zkittlez), comment.commentable
  end

  # === Scopes ===

  test "recent returns comments ordered by created_at desc" do
    recent = Comment.recent
    assert recent.first.created_at >= recent.last.created_at
  end

  test "by_user returns comments by specific user" do
    marcus_comments = Comment.by_user(users(:marcus))
    assert marcus_comments.all? { |c| c.user == users(:marcus) }
  end
end
