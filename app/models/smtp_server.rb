# == Schema Information
#
# Table name: smtp_servers
#
#  id            :integer          not null, primary key
#  host          :string(128)      not null
#  port          :integer          not null
#  domain        :string(128)      not null
#  user_name     :string(128)      not null
#  password      :string(128)      not null
#  from          :string(128)      not null
#  auth_kind     :string
#  auto_starttls :boolean          not null
#

# Credentials for sending e-mail via an SMTP server.
#
# This is currently a singleton, but we may end up with per-course SMTP servers
class SmtpServer < ApplicationRecord
  # The DNS name or IP address of the SMTP server.
  validates :host, presence: true, length: 1..128

  # The TCP port that the SMTP server listens to.
  validates :port, presence: true,
                   numericality: { integer_only: true, greater_than: 0 }

  # The domain used for HELO.
  validates :domain, length: 0..128

  # The user name required by the authentication process.
  validates :user_name, length: 0..128

  # The password required by the authentication process.
  validates :password, length: 0..128

  # The name and e-mail on the From line.
  validates :from, presence: true, length: 1..128

  # The authentication process used by the SMTP server.
  validates :auth_kind,
      inclusion: { in: %w(plain login cram_md5), allow_nil: true }
  # :nodoc: coerce an empty ('') auth_kind to nil
  def auth_kind=(new_auth_kind)
    new_auth_kind = nil if new_auth_kind.blank?
    super new_auth_kind
  end

  # If true, STARTTLS is used if the SMTP server supports it.
  validates :auto_starttls, inclusion: { in: [true, false], allow_nil: false }

  # Converts the information into ActionMailer's configuration format.
  #
  # @return {Hash} a value that can be assigned to
  #     config.action_mailer.smtp_settings
  def action_mailer_options
    options = { address: host, port: port,
                enable_starttls_auto: auto_starttls }
    options[:domain] = domain unless domain.empty?
    unless auth_kind.nil?
      options[:authentication] = auth_kind.to_sym
      options[:user_name] = user_name
      options[:password] = password
    end
    options
  end
end
