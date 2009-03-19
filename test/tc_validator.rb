require 'test/unit'
require 'dnsruby'
include Dnsruby

class TestValidator < Test::Unit::TestCase
  def test_validation
    Dnsruby::Dnssec.clear_trusted_keys
    Dnsruby::Dnssec.clear_trust_anchors
    res = Dnsruby::Resolver.new("dnssec.nominet.org.uk")
    res.dnssec=true

    trusted_key = Dnsruby::RR.create({:name => "uk-dnssec.nic.uk.",
        :type => Dnsruby::Types.DNSKEY,
        :key=> "AQPJO6LjrCHhzSF9PIVV7YoQ8iE31FXvghx+14E+jsv4uWJR9jLrxMYm sFOGAKWhiis832ISbPTYtF8sxbNVEotgf9eePruAFPIg6ZixG4yMO9XG LXmcKTQ/cVudqkU00V7M0cUzsYrhc4gPH/NKfQJBC5dbBkbIXJkksPLv Fe8lReKYqocYP6Bng1eBTtkA+N+6mSXzCwSApbNysFnm6yfQwtKlr75p m+pd0/Um+uBkR4nJQGYNt0mPuw4QVBu1TfF5mQYIFoDYASLiDQpvNRN3 US0U5DEG9mARulKSSw448urHvOBwT9Gx5qF2NE4H9ySjOdftjpj62kjb Lmc8/v+z"
      })
    ret = Dnsruby::Dnssec.add_trust_anchor_with_expiration(trusted_key, Time.now.to_i + 5000)

    r = res.query("aaa.bigzone.uk-dnssec.nic.uk", Dnsruby::Types.A)
    assert(r.security_level.code == Message::SecurityLevel::SECURE, "Level = #{r.security_level.string}")
    ret = Dnsruby::Dnssec.validate(r)
    assert(ret, "Dnssec validation failed")

    # @TODO@ Test other validation policies!!
  end

  def test_validator
    print "Test validation rom built-in anchors!\n"
    return
    res = Resolver.new
    res.dnssec=true
    # @TODO@ Really need to load some kind of anchor in here
    # Or rather, what should the configuration be for this?
    ret = res.query("nic.se", Types.A)
    assert(ret)
    assert(ret.security_level == Message::SecurityLevel::SECURE)
  end

  def test_resolver_cd_validation_fails
    # Should be able to check Nominet test-zone here - no keys point to it
    res = Resolver.new
    res.dnssec=true
    r = res.query("uk-dnssec.nic.uk", Dnsruby::Types.A)
    assert(r.security_level = Message::SecurityLevel::INSECURE)
  end

  # @TODO@ OTHER TESTS!!!
  def test_nsec
    print "Test NSEC handling in validation\n"
    # @TODO@
  end

  def test_nsec3
    print "Test NSEC3 handling in validation\n"
    # @TODO@
  end

  def test_eventtype_api
    # @TODO@ TEST THE Resolver::EventType interface!
    print "Test EventType API!\n"
  end

  def test_config_api
    # @TODO@ Test the different configuration options for the validator,
    # and their defaults
    #
    # Should be able to set :
    #  o Whether or not validation happens
    #  o The async API queue tuples etc.
    #  o Whether to use authoritative nameservers for validation
    #  o Whether to use authoritative nameservers generally
    #
    print "Test validation configuration options!\n"
  end


end