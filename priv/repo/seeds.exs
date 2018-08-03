# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     WebCAT.Repo.insert!(%WebCAT.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will halt execution if something goes wrong.

alias WebCAT.Factory

# Add some testing seed data

classroom = Factory.insert(:classroom)

user = Factory.insert(:user, classrooms: [classroom])
Factory.insert(:confirmation, user: user)
Factory.insert(:password_reset, user: user)

students = Factory.insert_list(4, :student, classroom: classroom)
rotation = Factory.insert(:rotation, classroom: classroom)

rotation_group =
  Factory.insert(:rotation_group, instructor: user, rotation: rotation, students: students)

main_category = Factory.insert(:category)
sub_categories = Factory.insert_list(3, :category, parent_category: main_category)
draft = Factory.insert(:draft, student: Enum.random(students), rotation_group: rotation_group)

observation =
  Factory.insert(
    :observation,
    category: Enum.random(sub_categories),
    rotation_group: rotation_group
  )

feedback = Factory.insert(:feedback, observation: observation)
Factory.insert(:explanation, feedback: feedback)

Factory.insert(:email, draft: draft)
Factory.insert(:notification, draft: draft, user: user)
