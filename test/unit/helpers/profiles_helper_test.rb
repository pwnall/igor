require 'test_helper'

class ProfilesHelperTest < ActionView::TestCase
  def test_mit_by_school
    assert_equal 'Massachusetts Institute of Technology',
        guess_university_from_athena(:school => 'School of Engineering',
          :address => '21 Wellesley College Rd #')
  end
  def test_mit_by_department
    assert_equal 'Massachusetts Institute of Technology',
        guess_university_from_athena(
          :department => 'Electrical Eng & Computer Sci',
          :address => '21 Wellesley College Rd #')
  end
  def test_mit_by_year
    assert_equal 'Massachusetts Institute of Technology',
        guess_university_from_athena(:year => '1',
          :address => '21 Wellesley College Rd #')    
  end
  def test_wellesley_by_keywords
    assert_equal 'Wellesley College',
        guess_university_from_athena(:name => 'John Harvard',
          :address => '21 Wellesley College Rd #', :city => 'Wellesley, MA')
  end
  def test_harvard_by_keywords
    assert_equal 'Harvard University',
        guess_university_from_athena(:name => 'John Harvard')
  end
end
