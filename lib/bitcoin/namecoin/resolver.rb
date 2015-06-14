
class Namecoin::Resolver

  def initialize chain
    @chain = chain
  end

  def resolve domain, types = [:ns, :ip]
    *subs, domain, tld = *domain.split(".")
    return nil  unless record = @chain.db[:names].where(name: "d/#{domain}").order(:txout_id).last
    value = JSON.parse(record[:value]) rescue return
    return nil  unless data = parse(subs.reverse, value)
    types.map(&:to_s).each {|t| return [t.to_sym, data[t]]  if data[t] }
    nil
  end

  def parse subs, data
    return parse(subs, data["map"][subs.shift] || data["map"]["*"])  if subs.any?
    return data  unless data && map = data["map"]
    if map[""]
      parse(subs, map[""])
    elsif map["*"]
      parse(subs, map["*"])
    end
  end

end
