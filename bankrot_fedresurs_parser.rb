# coding: utf-8

### отладка
#require 'pry'

# первым делом конфиг
require File.join( File.dirname(__FILE__), "bankrot_fedresurs_parser", "config" )

# логгер
require File.join( File.dirname(__FILE__), "bankrot_fedresurs_parser", "log" )
# общак
require File.join( File.dirname(__FILE__), "bankrot_fedresurs_parser", "shared" )

# геолокация
require File.join( File.dirname(__FILE__), "bankrot_fedresurs_parser", "geocoder" )
# список площадок
require File.join( File.dirname(__FILE__), "bankrot_fedresurs_parser", "platforms_list" )
# обработка основы
require File.join( File.dirname(__FILE__), "bankrot_fedresurs_parser", "process_fedresurs" )

# площадки
require File.join( File.dirname(__FILE__), "bankrot_fedresurs_parser", "platforms_params" )
require File.join( File.dirname(__FILE__), "bankrot_fedresurs_parser", "platforms_rules" )
require File.join( File.dirname(__FILE__), "bankrot_fedresurs_parser", "platforms_rules2" )
require File.join( File.dirname(__FILE__), "bankrot_fedresurs_parser", "platforms_rules3" )
require File.join( File.dirname(__FILE__), "bankrot_fedresurs_parser", "platforms" )

# база данных
require File.join( File.dirname(__FILE__), "bankrot_fedresurs_parser", "sqlite" )

# реп
require File.join( File.dirname(__FILE__), "bankrot_fedresurs_parser", "reporter" )

# ну и версия конечно
require File.join( File.dirname(__FILE__), "bankrot_fedresurs_parser", "version" )

### require для внешних
# require 'yaml' # => уже есть в config.rb
require 'watir-webdriver'
require 'watir-dom-wait'
require 'nokogiri'
require 'date'
require 'headless'
#require 'russian'  # => \  уже есть в geocoder.rb
#require 'geocoder' # =>  \

module BankrotFedresursParser

	###
	### Инициализация
	###

	# загрузка конфигураций
  #CFG = Config.new

  # собсна инициализация логгера
  Log.init

  # выхлоп конфигураций
  # показывается только для разработчика (см. config/default_config.yml#log_dbg)
  Log.dbg "url отправной точки: #{CFG.fedresurs_url}"
	Log.dbg "вид торгов - 'Публичое предложение' (значение поля '3'): #{CFG.vid_torgov}"
	Log.dbg "таймаут повторного запроса для форм, с: #{CFG.form_timeout}"
	Log.dbg "таймаут перехода по ссылкам, с: #{CFG.links_follow_timeout}"
	Log.dbg "файл базы данных: #{CFG.db_file}"
	Log.dbg "координаты: #{CFG.home_geolocation}"
	Log.dbg "максимальное удаление объекта, км: #{CFG.max_distance}"
	Log.dbg "лог-файл: #{CFG.logfile}"
	Log.dbg "направление(ия) выхлопа логов ( :both | :file | :stdout ): #{CFG.log_output}"
	Log.dbg "лог dbg-сообщений? (= да! - и это очевидно =): #{CFG.log_dbg}"


	START_TIME = Time.now

  # обработка собсна
  HEADLESS = Headless.new
	HEADLESS.start
  Fedresurs.init
  Fedresurs.process!
  Reporter.process!
  HEADLESS.destroy
end
