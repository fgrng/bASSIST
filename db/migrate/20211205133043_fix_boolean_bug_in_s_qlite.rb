class FixBooleanBugInSQlite < ActiveRecord::Migration[6.0]
  def up
    # Rails 6.0 Update
    # Fix bug in Rails SQLite Adapter. Update serialization of boolean values in DB.
    # See: https://stackoverflow.com/questions/6013121/rails-3-sqlite3-boolean-false
    # And: https://titanwolf.org/Network/Articles/Article?AID=13d09310-a5e1-4c5c-bede-f73276076e35

    # Exercise: visibility status
    Exercise.all.where("is_visible == 't'").update_all(is_visible: true)
    Exercise.all.where("is_visible == 'f'").update_all(is_visible: false)

    # Feedback: passing grade, visibility status
    Feedback.all.where("is_visible == 't'").update_all(is_visible: true)
    Feedback.all.where("is_visible == 'f'").update_all(is_visible: false)
    Feedback.all.where("passed == 't'").update_all(passed: true)
    Feedback.all.where("passed == 'f'").update_all(passed: false)

    # Lecture: visibility status, enrolling closed, show lsa feature
    Lecture.all.where("is_visible == 't'").update_all(is_visible: true)
    Lecture.all.where("is_visible == 'f'").update_all(is_visible: false)
    Lecture.all.where("closed == 't'").update_all(closed: true)
    Lecture.all.where("closed == 'f'").update_all(closed: false)
    Lecture.all.where("show_lsa_score == 't'").update_all(show_lsa_score: true)
    Lecture.all.where("show_lsa_score == 'f'").update_all(show_lsa_score: false)

    # Roles: validated status
    Role.all.where("validated == 't'").update_all(validated: true)
    Role.all.where("validated == 'f'").update_all(validated: false)

    # Submissions: visibility status, externaly changed status
    Submission.all.where("is_visible == 't'").update_all(is_visible: true)
    Submission.all.where("is_visible == 'f'").update_all(is_visible: false)
    Submission.all.where("external == 't'").update_all(external: true)
    Submission.all.where("external == 'f'").update_all(external: false)
  end
end
