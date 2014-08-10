require 'yaml'
config = YAML.load(open("config.yml"))

config.each do |k,v|
	ENV[k] = v
end