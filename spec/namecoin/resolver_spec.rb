# encoding: ascii-8bit

require_relative '../spec_helper.rb'
require 'bitcoin/script'

class Hash

  def deep_stringify_keys
    Hash[map {|k, v| [k.to_s, v.is_a?(Hash) ? v.deep_stringify_keys : v] }]
  end
  
end

describe Namecoin::Resolver do
  
  before do
    @chain = Bitcoin::Blockchain.create_store(:archive, db: "sqlite:/", log_level: :warn)
    @resolver = Namecoin::Resolver.new(@chain)
  end

  def test_data name, value
    @chain.db[:names].insert( txout_id: 0, name: name, value: value.deep_stringify_keys.to_json )    
  end
  
  it "should resolve simple IP record" do
    test_data "d/example", ip: "1.2.3.4"
    @resolver.resolve("example.bit").should == [:ip, "1.2.3.4"]
  end

  it "should resolve multiple IP records" do
    test_data "d/example", ip: ["1.2.3.4", "5.6.7.8"]
    @resolver.resolve("example.bit").should == [:ip, ["1.2.3.4", "5.6.7.8"]]
  end

  it "should resolve mapped IP record" do
    test_data "d/example", map: { "": { "ip": "1.2.3.4" } }
    @resolver.resolve("example.bit").should == [:ip, "1.2.3.4"]
    @resolver.resolve("sub.example.bit").should == nil
  end

  it "should resolve simple subdomain map" do
    test_data "d/example", map: { "www": { "ip": "1.2.3.4" } }
    @resolver.resolve("www.example.bit").should == [:ip, "1.2.3.4"]
  end

  it "should resolve nested subdomain map" do
    test_data "d/example", { map: { sub: { map: { www: { "ip": "1.2.3.4" } } } } }
    @resolver.resolve("www.sub.example.bit").should == [:ip, "1.2.3.4"]
  end

  it "should resolve wildcards" do
    test_data "d/example", { map: { "*": { "ip": "1.2.3.4" } } }
    @resolver.resolve("example.bit").should == [:ip, "1.2.3.4"]
    @resolver.resolve("sub.example.bit").should == [:ip, "1.2.3.4"]
  end

  it "should not resolve invalid records" do
    test_data "d/example", {}
    @resolver.resolve("example.bit").should == nil
  end

  it "should not resolve nonexistant names" do
    @resolver.resolve("example.bit").should == nil
  end

  it "should resolve other record types" do
    test_data "d/example", ipv6: "::1", whatever: "foobar"
    @resolver.resolve("example.bit", [:ipv6]).should == [:ipv6, "::1"]
    @resolver.resolve("example.bit", [:whatever]).should == [:whatever, "foobar"]
  end

end
