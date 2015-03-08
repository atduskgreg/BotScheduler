require 'dm-core'
require 'dm-timestamps'
require 'dm-migrations'
require 'dm-aggregates'
require 'pathname'

DataMapper.setup(:default, "#{Pathname(__FILE__).dirname.expand_path.to_s}/literal_devices.sqlite3"})

class Device
 
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String
  property :definition, Text
  property :example, Text
  property :source, String
end

DataMapper.finalize