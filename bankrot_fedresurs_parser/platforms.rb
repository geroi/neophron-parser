# coding: utf-8

####
##    platforms.rb
###
#

# обработка площадок

module BankrotFedresursParser

	module Platforms

		# Переход на площадку
		def self.process! params, pbrw
			Log.dbg "platforms > process! на входе\n" +
							"\tпараметры площадки: #{params}"
			Log.success "Обработка на площадке"
			
			PlatformsRules.send( params[:strategy], params, pbrw )

			### depricated
			#### выбор правила( стратегии ) и обработка
			###select_rule params[:strategy], pbrw
		end

		### depricated
		### # приватная зона
		### class << self
		### 
		### 	### depricated
		### 	#### подключение списка площадок
		### 	###include PlatformsList
		### 
		### 	# depricated
		### 	# подключение правил обработки площадок
		### 	#include PlatformsRules
		### 
		### 	### depricated
		### 	###private
		### 	###	def select_rule strategy, pbrw
		### 	###		PlatformsRules.send( strategy, pbrw )
		### 	###	end
		### 
		### # end of class << self
		### end

	# end of Platforms
	end

end