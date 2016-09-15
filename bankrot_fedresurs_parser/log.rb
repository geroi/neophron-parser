# coding: utf-8

####
##    log.rb
###
#

### Цвета для вывода в консоль

class String
	# красный для фейлов
  def red;            "\033[31m#{self}\033[0m" end
  # зелёный для саксесов
  def green;          "\033[32m#{self}\033[0m" end
  # жёлтый для варнингов
  def brown;          "\033[33m#{self}\033[0m" end
  # дебаг инфо
  def cyan;           "\033[36m#{self}\033[0m" end
  # обесцвечивание для записи в файл
  def no_colors; self.gsub( /\033\[\d+m/, '' ) end
end

### Логер

# В зависимости от конфигурации пишет в файл или в в консоль или и туда и туда
# заткнуть его совсем варианта нету

module BankrotFedresursParser

	module Log

		# заморожено
		# суммарная информация
		#@@sum = {}

		# префиксы соответственны
		# просто информация не имеет цвета
		def self.info( msg ); 		choose_out "INFO: #{msg}" 					end
		# фейлы
		def self.error( msg ); 		choose_out "ERROR: #{msg}".red 			end
		# збс
		def self.success( msg ); 	choose_out "SUCCESS: #{msg}".green	end
		# варнинги
		def self.warn( msg ); 		choose_out "WARN: #{msg}".brown 		end
		# информация для отладки
		# dbg-сообщения не имеют префикс в [] ( например [fedresurs] ) как
		# остальные виды сообщений. У них свой префикс:
		#   "имя_файла > название_метода [> блок в методе ( наример 'each' )]"
		def self.dbg( msg )
			choose_out "DBG: #{msg}".cyan if CFG.log_dbg
		end

		# живой выхлоп на консоль, без копии в файл ( обновление текущего значения )
		def self.live_update( msg )
			print "\r#{msg}"
		end
	
		# инициализация
		def self.init;	          File.new( CFG.logfile, 'w' )	      end

		#
		class << self
			# запретная зона - с фото- видеосъёмочой аппаратурой сюда нельзя
			private
				# выбор выхлопа - файл, stdout или оба
				def choose_out( msg )
					# добавление отметки времени
					msg = "[ #{Time.now.strftime('%H:%M:%S %-d/%-m/%y')} ] #{msg}"
					# выбор вывода: файл и stdout или то или то поодиночке
					case CFG.log_output
					when :both
					# оба
						File.open( CFG.logfile, 'a' ){ |f| f.puts msg.no_colors }
						puts msg
					when :file
					# только файл
						File.open( CFG.logfile, 'a' ){ |f| f.puts msg.no_colors }
					else # stdout
					# только stdout
						puts msg
					end # case
				end # def

			# end of private

		# end of class << self
		end

	# end of Log module
	end

# end of main module
end
