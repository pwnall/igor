# == Schema Information
#
# Table name: email_resolvers
#
#  id               :integer          not null, primary key
#  domain           :string(128)      not null
#  ldap_server      :text             not null
#  ldap_auth_dn     :text
#  ldap_password    :text             not null
#  ldap_search_base :text             not null
#  name_ldap_key    :text             not null
#  dept_ldap_key    :text             not null
#  year_ldap_key    :text             not null
#  user_ldap_key    :text             not null
#  use_ldaps        :boolean          not null
#

# Obtains profile information from an e-mail.
class EmailResolver < ApplicationRecord
  # The e-mail domain that can be handled by this resolver.
  validates :domain, presence: true, length: 1..128, uniqueness: true

  # The LDAP server used to resolve e-mails.
  validates :ldap_server, presence: true, length: 1..256

  # The DN used as a base (tree root) in LDAP searches.
  validates :ldap_search_base, length: { in: 0..256, allow_nil: false }

  # The DN used to authenticate to the LDAP server.
  #
  # If null, we use anonymous authentication. Otherwise, we use simple
  # authentication.
  validates :ldap_auth_dn, length: { in: 1..256, allow_nil: true }
  def ldap_auth_dn=(new_ldap_auth_dn)
    new_ldap_auth_dn = nil if new_ldap_auth_dn.blank?
    super new_ldap_auth_dn
  end

  # The password used to authenticate to the LDAP server.
  validates :ldap_password, length: { in: 0..256, allow_nil: false }

  # The name of the LDAP attribute that holds the user's full name.
  validates :name_ldap_key, presence: true, length: 1..256

  # The name of the LDAP attribute that holds the user's department.
  validates :dept_ldap_key, presence: true, length: 1..256

  # The name of the LDAP attribute that holds the user's year.
  validates :year_ldap_key, presence: true, length: 1..256

  # The name of the LDAP attribute that holds the user's username.
  validates :user_ldap_key, presence: true, length: 1..256


  # True if LDAP over TLS should be used.
  validates :use_ldaps, inclusion: { in: [true, false], allow_nil: false }

  def self.resolve(email)
    return nil unless resolver = self.for_email(email)
    resolver.resolve email
  end

  # The Resolver instance that can look up a given e-mail address.
  #
  # @param {String} email the e-mail address to be resolved
  # @return {EmailResolver} nil if no resolver is set up for the domain in the
  #   given e-mail address
  def self.for_email(email)
    domain = email.split('@', 2).last
    where(domain: domain).first
  end

  def resolve(email)
    ldap_results = ldap_email_search email
    return nil if ldap_results.empty?
    ldap_result = ldap_results.first

    {
      full_name: (ldap_result[name_ldap_key] || []).first,
      department: (ldap_result[dept_ldap_key] || []).first,
      year: (ldap_result[year_ldap_key] || []).first,
      username: (ldap_result[user_ldap_key] || []).first,
    }
  end

  # Performs a LDAP search.
  def ldap_email_search(email)
    filter = net_ldap_search_filter email
    Net::LDAP.open net_ldap_options do |ldap|
      ldap.search base: ldap_search_base, filter: filter, return_result: true
    end
  end

  # @return {Net::LDAP::Filter} the filter used to search for an e-mail address
  def net_ldap_search_filter(email)
    username, _ = *email.split('@', 2)
    Net::LDAP::Filter.eq('mail', email) | Net::LDAP::Filter.eq('uid', username)
  end

  # @return {Hash} the options used to construct a Net::LDAP connection
  def net_ldap_options
    host, port_string = *ldap_server.split(':', 2)
    default_port = use_ldaps? ? 636 : 389
    port = (port_string || default_port).to_i

    if ldap_auth_dn.blank?
      auth = { method: :anonymous }
    else
      auth = { method: :simple, username: ldap_auth_dn,
               password: ldap_password }
    end

    options = { host: host, port: port, auth: auth }
    options[:encryption] = :simple_tls if use_ldaps?

    options
  end
end
