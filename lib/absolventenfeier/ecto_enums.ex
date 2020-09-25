import EctoEnum

defenum(CourseType, :course_type, [
  :none,
  :information_systems,
  :business_economics,
  :economics,
  :interdisciplinary_studies
])

defenum(DegreeType, :degree_type, [
  :none,
  :bachelor,
  :master
])

defenum(UserRole, :user_role, [
  :user,
  :admin,
  :mollie
])

defenum(TermType, :term_type, [
  :summer_term,
  :winter_term
])
