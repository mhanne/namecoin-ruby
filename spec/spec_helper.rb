# encoding: ascii-8bit
$: << File.expand_path(File.join(File.dirname(__FILE__), '/../lib'))

#begin
  require 'simplecov'
  SimpleCov.start
#rescue LoadError
#end

require 'bundler'
Bundler.setup
require 'bitcoin'
require 'bitcoin/namecoin'

begin
  require 'minitest'
rescue LoadError
end
require 'minitest/mock'
include MiniTest


include Bitcoin::Builder

# create block for given +prev+ block
# if +store+ is true, save it to @store
# accepts an array of +tx+ callbacks
def create_block prev, store = true, tx = [], key = @key, coinbase_value = 50e8, opts = {}
  key ||= Bitcoin::Key.generate
  opts[:bits] ||= Bitcoin.network[:proof_of_work_limit]
  block = build_block(Bitcoin.decode_compact_bits(opts[:bits])) do |b|
    b.time opts[:time]  if opts[:time]
    b.prev_block prev
    b.tx do |t|
      t.input {|i| i.coinbase }
      t.output {|o| o.value coinbase_value; o.script {|s| s.recipient key.addr } }
    end
    tx.each {|cb| b.tx {|t| cb.call(t) } }
  end
  @store.store_block(block)  if store
  block
end

# create transaction given builder +tx+
# +outputs+ is an array of [value, key] pairs
def create_tx(tx, prev_tx, prev_out_index, outputs, key = @key)
  tx.input {|i| i.prev_out prev_tx; i.prev_out_index prev_out_index; i.signature_key key }
  outputs.each do |value, key|
    tx.output {|o| o.value value; o.script {|s| s.recipient key.addr } }
  end
end

# create a chain of +n+ blocks, based on +prev_hash+ block.
# influence chain properties via options:
#  time: start time all other times are based on
#  interval: time between blocks
#  bits: target bits each block must match
def create_blocks prev_hash, n, opts = {}
  interval = opts[:interval] || 600
  time = opts[:time] || Time.now.to_i
  bits = opts[:bits] || 553713663
  block = @store.get_block(prev_hash)
  n.times do |i|
    block = create_block block.hash, true, [], @key, 50e8, {
      time: time += interval, bits: bits }
    # block = @store.get_block(block.hash)
    # puts "#{i} #{block.hash[0..8]} #{block.prev_block.reverse_hth[0..8]} #{Time.at(block.time).strftime('%Y-%m-%d %H:%M:%S')} c: #{block.chain} b: #{block.bits} n: #{block.nonce} w: #{block.work}"
  end
  block
end
