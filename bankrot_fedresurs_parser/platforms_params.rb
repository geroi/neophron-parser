# coding: utf-8

####
##    platform_params.rb
###
#

# получение параметров из федресурса
# по id площадки

module BankrotFedresursParser

	module PlatformsParams

		#
		def self.get_params_by_row td_ary, id # ,brw
			Log.dbg "platforms_params > get_params_by_row"
			
			# отладка
			#binding.pry

			strategy = strategy_by_id( id )
			# log
			Log.dbg "platforms_params > get_params_by_row (середина)\n" +
			        "\tid: #{id}" +
			        "\tstrategy: #{strategy}"
			# выбор стратегии
			case strategy
			when :type2
				return get_params_for_type2( id, strategy, td_ary )
			when :type1, :lot_online, :m_ets, :sberbank_ast, :el_torg, :cdtrf
				return get_params_for_type1( id, strategy, td_ary )
			when :b2b_center
				return get_params_for_b2b_center( id, strategy, td_ary )
			when :fabrikant
				return get_params_for_fabrikant( id, strategy, td_ary )
			when :sibtoptrade
				return get_params_for_sibtoptrade( id, strategy, td_ary )
			# frozen
			#when :any_platform
				#return get_params_for_any_platform( params )
			else
				Log.warn "Нет информации о площадке #{id}, пропуск"
				return false
			end
		end

		# частная территория
		class << self

			# подключение списка
			include PlatformsList

			private
				#
				def get_params_for_type2( id, strategy, td_ary )
					# номер торгов как он в таблице
					trade_number = td_ary[0].text.strip
					# для type2 пид его следующий:
					#    ПП-14238/1
					#    ПП    - это значит "публичное предложение"
					#    14238 - номер публичного предложения
					#    1     - номер лота
					# Больше информации и не требуется
					# Обрезка 'ПП-'
					trade_number = trade_number[3..-1]
					# формаирование параметров
					{
						url:      url_by_id( id ),
						id:       id,
						strategy: strategy,
						pp_num:   trade_number[/^\d+/],
						lot_num:  trade_number[/\d+$/]
					}
				end

				def get_params_for_type1( id, strategy, td_ary )
					# номер торгов как он в таблице
					trade_number = td_ary[0].text.strip
					# формаирование параметров
					{
						url:          url_by_id( id ),
						id:           id,
						strategy:     strategy,
						trade_number: trade_number
					}
				end

				def get_params_for_b2b_center( id, strategy, td_ary )
					trade_number = td_ary[0].text.strip[/\(\d+\)/][1...-1]
					{
						url:          url_by_id( id ),
						id:           id,
						strategy:     strategy,
						trade_number: trade_number
					}
				end

				def get_params_for_fabrikant( id, strategy, td_ary )
					trade_number = td_ary[0].text.strip[/\d+/]
					{
						url:          url_by_id( id ),
						id:           id,
						strategy:     strategy,
						trade_number: trade_number
					}
				end

				#sibtoptrade
				def get_params_for_sibtoptrade( id, strategy, td_ary )
					trade_number = td_ary[0].text.strip
					debtor       = td_ary[4].text.strip
					{
						url:          url_by_id( id ),
						id:           id,
						strategy:     strategy,
						trade_number: trade_number,
						debtor: 			debtor
					}
				end

		# end of class << self
		end

	end

end


