require 'text/hyphen'
require 'marky_markov'
require 'pathname'
require 'yaml'

# require Pathname(__FILE__).dirname.expand_path.to_s + '/models'
require Pathname(__FILE__).dirname.parent.expand_path.to_s + '/models'

class LiteralDevicesBot
  def bot
    @bot ||= Bot.first :handle => "literaldevices"
  end

  def handle
    bot.handle
  end

  def next_tweet
    markov = MarkyMarkov::Dictionary.new("#{Pathname(__FILE__).dirname.expand_path}/devices-definition-dictionary")

    hh = Text::Hyphen.new(:language => 'en_us', :left => 0, :right => 0)
    
    devices = YAML.load(open("#{Pathname(__FILE__).dirname.expand_path}/devices.yml").read)
    names = devices.select{|d| d[:source] == "devices"}.collect{|d| d[:name]}.select{|i| i.length > 1}

    # names =  DataMapper.repository(:literal_devices) do
    #   Device.all.select{|d| d.source == "devices"}.collect(&:name).select{|i| i.length > 1}
    # end 

    names = names.collect{|n| hh.visualize(n).split("-")}
    

    term = nil
    if rand > 0.5
      set = (0..2).collect{names.sample}
      # puts set.inspect
      term = "#{set[0][0]}#{set[1][set[1].length/2]}#{set[2].last}"
    else
      set = (0..3).collect{names.sample}
      # puts set.inspect
      term = "#{set[0][0]}#{set[1][set[1].length/2]}#{set[2][set.length/2]}#{set[3].last}"
    end
    
    result = "\"#{term.downcase.capitalize}\" is #{markov.generate_n_sentences(1).downcase}"
    while result.length > 140
      result = "\"#{term.downcase.capitalize}\" is #{markov.generate_n_sentences(1).downcase}"
    end

    return bot.tweets.create :text => result
    
  end
end


