require 'test_helper'

class ProfilesHelperTest < ActionView::TestCase
  include ProfilesHelper

  describe '#email_format_check' do
    it 'returns nil if the e-mail is blank' do
      assert_nil email_format_check('')
    end

    it 'gives a warning if the e-mail is too short' do
      assert_match /too short/, email_format_check('asdf')
    end

    it 'gives a warning if a user with that e-mail already exists' do
      existing_email = users(:dexter).email
      assert_match /taken/, email_format_check(existing_email)
    end

    it 'gives a warning if the TLD is not .edu' do
      assert_match /must be an .edu/, email_format_check('asdf@asdf.com')
    end

    it 'gives positive feedback if the e-mail format is valid' do
      assert_match /available/, email_format_check('unused@mit.edu')
    end
  end

  describe '#email_resolver_check' do
    it 'returns nil if the e-mail is blank' do
      assert_nil email_resolver_check(nil, '')
    end

    it 'gives a warning if the e-mail failed to resolve' do
      assert_match /not found/, email_resolver_check(nil, 'missing@mit.edu')
    end

    it 'gives positive feedback if the e-mail was resolved' do
      email = 'found@mit.edu'
      assert_match /#{email} found/, email_resolver_check({}, email)
    end
  end
end
