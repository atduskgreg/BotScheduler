require 'yaml'
config = YAML.load_file("config.yml")

config.each do |k,v|
	ENV[k] = v
end