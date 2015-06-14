# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "bitcoin/namecoin/version"

Gem::Specification.new do |s|
  s.name        = "namecoin-ruby"
  s.version     = "0.0.1"
  s.authors     = ["Marius Hanne"]
  s.email       = ["marius.hanne@sourceagency.org"]
  s.summary     = %q{namecoin support for bitcoin-ruby}
  s.description = %q{namecoin support for bitcoin-ruby and friends}
  s.homepage    = "https://github.com/mhanne/namecoin-ruby"
  s.license     = "MIT"

  # s.rubyforge_project = "namecoin-ruby"

  s.files         = [
    "lib/bitcoin/namecoin.rb",
    "lib/bitcoin/namecoin/version.rb",
  ]
  s.test_files    = [
    "spec/spec_helper.rb",
    "spec/namecoin/namecoin_spec.rb",
  ]
  s.executables   = ["namecoin_node", "namecoin_resolver"]
  s.require_paths = ["lib"]

  s.required_rubygems_version = ">= 1.3.6"

  # s.add_dependency "bitcoin-ruby"
  # s.add_dependency "bitcoin-ruby-blockchain"
  # s.add_dependency "bitcoin-ruby-node"

end
