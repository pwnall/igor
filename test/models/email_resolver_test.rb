require 'test_helper'

class EmailResolverTest < ActiveSupport::TestCase
  before do
    @resolver = EmailResolver.new domain: 'example2.com',
        ldap_server: 'ldap.forumsys.com:389',
        ldap_auth_dn: 'cn=read-only-admin,dc=example,dc=com',
        ldap_password: 'password',
        ldap_search_base: 'ou=scientists,dc=example,dc=com',
        name_ldap_key: 'CN', year_ldap_key: 'mitDirStudentYear',
        dept_ldap_key: 'ou', user_ldap_key: 'DN', use_ldaps: false
  end

  it 'validates the setup resolver' do
    assert @resolver.valid?, @resolver.errors.full_messages
  end

  it 'requires a domain' do
    @resolver.domain = nil
    assert @resolver.invalid?
  end

  it 'requires a unique domain' do
    @resolver.domain = email_resolvers(:public_ldap).domain
    assert @resolver.invalid?
  end

  it 'requires a server' do
    @resolver.ldap_server = nil
    assert @resolver.invalid?
  end

  it 'accepts a nil authentication DN' do
    @resolver.ldap_auth_dn = nil
    assert @resolver.valid?, @resolver.errors.full_messages
  end

  it 'coerces a blank authentication DN to nil' do
    @resolver.ldap_auth_dn = ''
    assert_equal nil, @resolver.ldap_auth_dn

    @resolver.ldap_auth_dn = '    '
    assert_equal nil, @resolver.ldap_auth_dn
  end

  it 'requires a non-nil LDAP password' do
    @resolver.ldap_password = nil
    assert @resolver.invalid?
  end

  it 'acceps a blank LDAP password' do
    @resolver.ldap_password = ''
    assert @resolver.valid?, @resolver.errors.full_messages
  end

  it 'requires a search base' do
    @resolver.ldap_search_base = nil
    assert @resolver.invalid?
  end

  it 'requires a name LDAP attribute' do
    @resolver.name_ldap_key = nil
    assert @resolver.invalid?
  end

  it 'requires a department LDAP attribute' do
    @resolver.dept_ldap_key = nil
    assert @resolver.invalid?
  end

  it 'requires a year LDAP attribute' do
    @resolver.year_ldap_key = nil
    assert @resolver.invalid?
  end

  it 'requires a username LDAP attribute' do
    @resolver.user_ldap_key = nil
    assert @resolver.invalid?
  end

  it 'requires a LDAPS flag' do
    @resolver.use_ldaps = nil
    assert @resolver.invalid?
  end

  describe '#net_ldap_options' do
    it 'handles non-encrypted authenticated connections' do
      resolver = EmailResolver.new ldap_server: 'ldap.forumsys.com:42',
          ldap_auth_dn: 'cn=read-only-admin,dc=example,dc=com',
          ldap_password: 'password', use_ldaps: false
      golden_options = {
        host: 'ldap.forumsys.com', port: 42,
        auth: { method: :simple, password: 'password',
                username: 'cn=read-only-admin,dc=example,dc=com' } }

      assert_equal golden_options, resolver.net_ldap_options
    end

    it 'handles encrypted non-authenticated connections' do
      resolver = EmailResolver.new ldap_server: 'ldap.forumsys.com:42',
          ldap_auth_dn: '', ldap_password: 'password', use_ldaps: true
      golden_options = {
        host: 'ldap.forumsys.com', port: 42,
        auth: { method: :anonymous }, encryption: :simple_tls }

      assert_equal golden_options, resolver.net_ldap_options
    end

    it 'uses the correct default port for non-encrypted connections' do
      resolver = EmailResolver.new ldap_server: 'ldap.forumsys.com',
          ldap_auth_dn: '', ldap_password: 'password', use_ldaps: false
      golden_options = {
        host: 'ldap.forumsys.com', port: 389,
        auth: { method: :anonymous } }

      assert_equal golden_options, resolver.net_ldap_options
    end

    it 'uses the correct default port for encrypted connections' do
      resolver = EmailResolver.new ldap_server: 'ldap.forumsys.com',
          ldap_auth_dn: 'cn=read-only-admin,dc=example,dc=com',
          ldap_password: 'password', use_ldaps: true
      golden_options = {
        host: 'ldap.forumsys.com', port: 636,
        auth: { method: :simple, password: 'password',
                username: 'cn=read-only-admin,dc=example,dc=com' },
        encryption: :simple_tls }

      assert_equal golden_options, resolver.net_ldap_options
    end
  end

  describe '#net_ldap_search_filter' do
    it 'works on a straightforward e-mail' do
      filter = @resolver.net_ldap_search_filter 'pwnall@example2.com'
      assert_instance_of Net::LDAP::Filter, filter
      assert_equal '(|(mail=pwnall@example2.com)(uid=pwnall))',
                   filter.to_rfc2254
    end
  end

  describe '#ldap_email_search' do
    it 'works with the public ldap' do
      @resolver.expects(:net_ldap_search_filter).with('einstein@example.com').
          returns(Net::LDAP::Filter.eq('cn', 'Scientists'))
      results = @resolver.ldap_email_search('einstein@example.com')
      assert_operator results.length, :>=, 1
      assert_equal 'Scientists', results.first['cn'].first
      assert_equal 'scientists', results.first['ou'].first
    end
  end

  describe '#resolve' do
    it 'maps an LDAP response to a hash correctly' do
      @resolver.expects(:ldap_email_search).with('einstein@example.com').
          returns([{ 'CN' => ['Albert Einstein'],
          'DN' => ['einstein'], 'mitDirStudentYear' => ['G'],
          'ou' => ['Scientists'] }])

      golden = { full_name: 'Albert Einstein', department: 'Scientists',
                 year: 'G', username: 'einstein' }
      assert_equal golden, @resolver.resolve('einstein@example.com')
    end

    it 'returns nil for an empty LDAP response' do
      @resolver.expects(:ldap_email_search).with('einstein@example.com').
          returns([])
      assert_equal nil, @resolver.resolve('einstein@example.com')
    end

    it 'handles missing attributes in LDAP response' do
      @resolver.expects(:ldap_email_search).with('einstein@example.com').
          returns([{}])

      golden = { full_name: nil, department: nil, year: nil, username: nil }
      assert_equal golden, @resolver.resolve('einstein@example.com')
    end

    it 'extracts information from a public LDAP response' do
      @resolver.expects(:net_ldap_search_filter).with('einstein@example.com').
          returns(Net::LDAP::Filter.eq('cn', 'Scientists'))

      golden = { full_name: 'Scientists', department: 'scientists', year: nil,
                 username: 'ou=scientists,dc=example,dc=com' }
      assert_equal golden, @resolver.resolve('einstein@example.com')
    end
  end

  describe '.for_email' do
    it 'finds the correct resolver for an existing domain' do
      assert_equal email_resolvers(:public_ldap),
          EmailResolver.for_email('einstein@example.com')
    end

    it 'returns nil for non-existing domain' do
      assert_equal email_resolvers(:public_ldap),
          EmailResolver.for_email('einstein@example.com')
    end
  end

  describe '.resolve' do
    it 'returns nil for e-mail on non-existing domain' do
      @resolver.expects(:net_ldap_search_filter).never
      assert_equal nil, EmailResolver.resolve('nobody@nowhere.com')
    end
  end
end
