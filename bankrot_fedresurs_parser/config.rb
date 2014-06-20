# coding: utf-8

####
##    config.rb
###
#

# Чтение конфигурационного файла, или использование настроек по умолчанию

require 'yaml'


module BankrotFedresursParser
	class Config
		#attr_accessor :config

		def initialize
			# конфигурации по умлочанию
			configurations = YAML.load_file( './config/default_config.yml' )
			# если передан свой конфиг, то берём его
			if ARGV[0]
				configurations.update YAML.load_file( ARGV[0] )
			end
			# преобразуем в методы
			configurations.each do |k, v|
				self.class.send :define_method, k do v end
			end
		end

	end

	# загрузка конфигураций
  CFG = Config.new

end

