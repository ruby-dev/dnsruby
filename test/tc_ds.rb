require 'test/unit'
require 'dnsruby'

class DsTest < Test::Unit::TestCase
  INPUT = "dskey.example.com. 86400 IN DS 60485 5 1 ( 2BB183AF5F22588179A53B0A" + 
    "98631FAD1A292118 )"
     DNSKEY = "dskey.example.com. 86400 IN DNSKEY 256 3 5 ( AQOeiiR0GOMYkDshWoSKz9Xz" +
                                                "fwJr1AYtsmx3TGkJaNXVbfi/" +                                                
                                                "2pHm822aJ5iI9BMzNXxeYCmZ"+
                                                "DRD99WYwYqUSdjMmmAphXdvx"+
                                                "egXd/M5+X7OrzKBaMbCVdFLU"+
                                                "Uh6DhweJBjEVv5f2wwjM9Xzc"+
                                                "nOf+EPbtG9DMBmADjFDc2w/r"+
                                                "ljwvFw== )" #  key id = 60485
      DS1 = "dskey.example.com. 86400 IN DS 60485 5 1 ( 2BB183AF5F22588179A53B0A"+
                                              "98631FAD1A292118 )"
      DS2 = "dskey.example.com. 86400 IN DS 60485 5 2   ( D4B7D520E7BB5F0F67674A0C"+
                                                "CEB1E3E0614B93C4F9E99B83"+
                                                "83F6A1E4469DA50A )"
  include Dnsruby
  def test_ds_from_string
    ds = Dnsruby::RR.create(INPUT)
    assert_equal(60485, ds.key_tag)
    assert_equal(Algorithms.RSASHA1, ds.algorithm)
    assert_equal(1, ds.digest_type)
    assert_equal("2BB183AF5F22588179A53B0A98631FAD1A292118", ds.digest)
    
    ds2 = Dnsruby::RR.create(ds.to_s)
    assert(ds2.to_s == ds.to_s)
  end

  def test_ds_from_data
    ds = Dnsruby::RR.create(INPUT)
    m = Dnsruby::Message.new
    m.add_additional(ds)
    data = m.encode
    m2 = Dnsruby::Message.decode(data)
    ds3 = m2.additional()[0]
    assert_equal(ds.to_s, ds3.to_s)
  end
  
  def test_ds_values
    ds = Dnsruby::RR.create(INPUT)
    ds.digest_type = 2
    begin
      ds.digest_type = 3
      fail
      
    rescue DecodeError
    end
  end
  
  def test_ds_digest
     key = Dnsruby::RR.create(DNSKEY)
     
     # and check it is the same as DS
     right_ds = Dnsruby::RR.create(DS1)
     ds = Dnsruby::RR::DS.from_key(key, 1);
     assert_equal(ds.to_s, right_ds.to_s)    
  end
  
  def test_sha2
     # Create a new DS from the DNSKEY, 
     key = Dnsruby::RR.create(DNSKEY)
     
     # and check it is the same as DS
     right_ds = Dnsruby::RR.create(DS2)
     ds = Dnsruby::RR::DS.from_key(key, 2);
     assert_equal(ds.to_s, right_ds.to_s)
  end
  
end