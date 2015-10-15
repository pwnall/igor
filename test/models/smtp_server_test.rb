require 'test_helper'

class SmtpServerTest < ActiveSupport::TestCase
  before do
    @server = SmtpServer.new host: 'smtp.gmail.com', port: 587,
        domain: 'gmail.com', user_name: 'seven_test@gmail.com',
        password: 'pa55w0rd', auth_kind: 'plain', auto_starttls: true
  end

  it 'validates the setup server' do
    assert @server.valid?, @server.errors.full_messages
  end

  it 'requires a host' do
    @server.host = nil
    assert @server.invalid?
  end

  it 'requires a port' do
    @server.port = nil
    assert @server.invalid?
  end

  it 'requires a domain' do
    @server.domain = nil
    assert @server.invalid?
  end

  it 'accepts an empty domain' do
    @server.domain = ''
    assert @server.valid?, @server.errors.full_messages
  end

  it 'requires a user name' do
    @server.user_name = nil
    assert @server.invalid?
  end

  it 'accepts an empty user name' do
    @server.user_name = ''
    assert @server.valid?, @server.errors.full_messages
  end

  it 'requires a password' do
    @server.password = nil
    assert @server.invalid?
  end

  it 'accepts an empty password' do
    @server.password = ''
    assert @server.valid?, @server.errors.full_messages
  end

  it 'accepts a nil authentication mode' do
    @server.auth_kind = nil
    assert @server.valid?, @server.errors.full_messages
  end

  it 'coerces an empty authentication mode to nil' do
    @server.auth_kind = ''
    assert_equal nil, @server.auth_kind
    assert @server.valid?, @server.errors.full_messages
  end

  it 'requires an auto STARTTLS option' do
    @server.auto_starttls = nil
    assert @server.invalid?
  end

  describe '#action_mailer_options' do
    it 'works for plain authentication' do
      golden = {
        address: 'smtp.gmail.com', port: 587, domain: 'gmail.com',
        user_name: 'seven_test@gmail.com', password: 'pa55w0rd',
        authentication: :plain, enable_starttls_auto: true
      }
      assert_equal golden, @server.action_mailer_options
    end

    it 'works for no authentication' do
      server = SmtpServer.new host: 'outgoing.mit.edu', port: 25,
          domain: 'mit.edu', user_name: '', password: '', auth_kind: '',
          auto_starttls: false
      golden = {
        address: 'outgoing.mit.edu', port: 25, domain: 'mit.edu',
        enable_starttls_auto: false
      }
      assert_equal golden, server.action_mailer_options
    end

    it 'works for the MIT insecure SMTP server' do
      server = SmtpServer.new host: 'outgoing.mit.edu', port: 25,
          domain: 'mit.edu', user_name: '', password: '', auth_kind: '',
          auto_starttls: true
      golden = {
        address: 'outgoing.mit.edu', port: 25, domain: 'mit.edu',
        enable_starttls_auto: true
      }
      assert_equal golden, server.action_mailer_options
    end
  end
end
