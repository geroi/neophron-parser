# coding: utf-8

####
##    platforms_rules2.rb
###
#

# правила для обработки площадок b2b_center

module BankrotFedresursParser

	module PlatformsRules

		# частная территория
		class << self
			#
			include Shared

			#
			private
				#
				# b2b
				def b2b_center params, pbrw
					Log.dbg "b2b id: #{params[:id]}, trade_number: #{params[:trade_number]}"
					# итак в параметрах уже есть всё необходимое
					# браузер открыт на нужной странице,
					# поехали

					# смена страницы на нужную
					wait_timeout( CFG.links_follow_timeout )
					pbrw.goto(
						"http://www.b2b-center.ru/market/view.html?id=#{params[:trade_number]}"
						)
					wait_when_dom_changed pbrw.body
					#

					# ноко
					page = Nokogiri::HTML( pbrw.html )

					# table present?
					if ( tbl = page.at('#auction_info_td > table') ).nil?
						Log.error "Данные не получены, пропуск\n"
					  	        "\turl: #{pbrw.url}" +
					    	      "\tNo.: #{params[:trade_number]}"
					end

#auction_info_td > table > tbody > tr:nth-child(1) > td > h2

					subject = tbl.at('tbody > tr:nth-child(1) > td > h2').text.strip
					description = tbl.at('tbody > tr:nth-child(4) > td > table > tbody > tr:nth-child(6) > td').text.strip

					dep = tbl.at('tbody > tr:nth-child(4) > td > table > tbody > tr:nth-child(1) > td:nth-child(2)').text.strip

					lot = Lot.find_or_create_by_url( pbrw.url )

					lot.update_attributes(
						subject:     subject,
						description: description,
						platform_id: Platform.find_or_create_by_number( params[:id] ).id
						)

					tbl = tbl.at('tbody > tr:nth-child(2) > td > table > tbody > tr:nth-child(7) > td:nth-child(2) > table')

					Log.success "Лот"
					Log.success "\tнаименование: #{subject}"
					Log.success "\tсведения:     #{description}"
					Log.success "\turl:          #{pbrw.url}"

					#reduction
					reduction =	tbl.css('tr')
					reduction.shift

					st_d, en_d = nil

					reduction.each_with_index do |tr,i|
						next if i == ( reduction.size - 1 )
							#
						begin
							st_d = DateTime.parse( "#{tr.at('td').text.strip} +0400" ).to_time
						rescue ArgumentError
							st_d = ""
						end
						begin
							en_d = DateTime.parse( "#{reduction[i+1].at('td').text.strip} +0400" ).to_time
						rescue ArgumentError
							en_d = ""
						end

							price = tr.css('td')[1].text.strip
							#
							Interval.create(
								start_date: st_d,
								end_date:   en_d,
								price:      price,
								deposit:    dep,
								lot_id:     lot.id
								)
							#
							Log.success "Интервал"
							Log.success "\tдата начала:    #{st_d}"  if st_d
					  	Log.success "\tдата окончания: #{en_d}"  if en_d
					  	Log.success "\tзадаток:        #{dep}"   if dep
					  	Log.success "\tцена:           #{price}" if price
					end

				# если в федресурсе лот есть, а на площадке его нету
				# обработка ошибки не найденого элемента
				rescue Watir::Exception::UnknownObjectException
					Log.error "Данные не получены, пропуск\n"
					          "\turl: #{pbrw.url}" +
					          "\tNo.: #{params[:trade_number]}"
				rescue NoMethodError
					Log.error "Данные не получены, пропуск\n"
					          "\turl: #{pbrw.url}" +
					          "\tNo.: #{params[:trade_number]}"
				rescue Net::ReadTimeout
					Log.error "Истекло время ожидания при подключении, пропуск\n" +
					          "\turl: #{pbrw.url}" +
					          "\tNo.: #{params[:trade_number]}"
				# end of b2b_center
				end

				# fabrikant
				def fabrikant params, pbrw
					Log.dbg "fabrikant id: #{params[:id]}, trade_number: #{params[:trade_number]}"
					# итак в параметрах уже есть всё необходимое
					# браузер открыт на нужной странице,
					# поехали

					# смена страницы на нужную
					wait_timeout( CFG.links_follow_timeout ) do
						pbrw.goto(
							"http://www.fabrikant.ru/market/view.html?action=view_auction&id=#{params[:trade_number]}"
							)
						wait_when_dom_changed pbrw.body
					end
					#

					# ноко
					page = Nokogiri::HTML( pbrw.html )

					subject = page.at('body > table:nth-child(2) > tbody > tr > td > table:nth-child(6) > tbody > tr > td.body_text > h1').text[/\".*\"/][1...-1]

					description = page.at('body > table:nth-child(2) > tbody > tr > td > table:nth-child(6) > tbody > tr > td.body_text > table > tbody > tr:nth-child(9) > td:nth-child(2)').text

					dep = nil # no info

					lot = Lot.find_or_create_by_url( pbrw.url )

					lot.update_attributes(
						subject:     subject,
						description: description,
						platform_id: Platform.find_or_create_by_number( params[:id] ).id
						)

					tbl = page.at('body > table:nth-child(2) > tbody > tr > td > table:nth-child(6) > tbody > tr > td.body_text > table > tbody > tr:nth-child(17) > td:nth-child(2)').children

					Log.success "Лот"
					Log.success "\tнаименование: #{subject}"
					Log.success "\tсведения:     #{description}"
					Log.success "\turl:          #{pbrw.url}"

					#reduction
					tbl.each_slice(2) do |e|
						begin
							st_d = DateTime.parse("#{e[0].text.strip[/.*:\d\d:/]} +0400").to_time
						rescue ArgumentError
							st_d = ""
						end
						price = e[0].text.strip.gsub(/.*:\W+(.*)$/,'\1')
						Interval.create(
							start_date: st_d,
							price:      price,
							lot_id:     lot.id
							)
					end

				# если в федресурсе лот есть, а на площадке его нету
				# обработка ошибки не найденого элемента
				rescue Watir::Exception::UnknownObjectException
					Log.error "Данные не получены, пропуск\n"
					          "\turl: #{pbrw.url}" +
					          "\tNo.: #{params[:trade_number]}"
				rescue NoMethodError
					Log.error "Данные не получены, пропуск\n"
					          "\turl: #{pbrw.url}" +
					          "\tNo.: #{params[:trade_number]}"
				rescue Net::ReadTimeout
					Log.error "Истекло время ожидания при подключении, пропуск\n" +
					          "\turl: #{pbrw.url}" +
					          "\tNo.: #{params[:trade_number]}"
				# end of fabrikant
				end

				def lot_online params, pbrw
					Log.dbg "lot_online id: #{params[:id]}, trade_number: #{params[:trade_number]}"

					wait_timeout( CFG.links_follow_timeout )
					pbrw.goto "http://bankruptcy.lot-online.ru/e-auction/auctionLotProperty.xhtml?parm=organizerUnid%3D1%3BlotUnid%3D#{params[:trade_number]}%3Bmode%3Djust"

					page = Nokogiri::HTML( pbrw.html )
					subject = page.at('#new-form-prop > table td h1').text.strip
					description = page.at('#new-form-prop > div > div.product > div').text.strip
					lot = Lot.find_or_create_by_url( pbrw.url )
					lot.update_attributes(
						subject:     subject,
						description: description,
						platform_id: Platform.find_or_create_by_number( params[:id] ).id
						)
					Log.success "Лот"
					Log.success "\tнаименование: #{subject}"
					Log.success "\tсведения:     #{description}"
					Log.success "\turl:          #{pbrw.url}"
					# interval
					st_d, en_d, price, info = nil
					price = page.xpath('//*[@id="formMain:opCostBValue"]/p/span').first.text.strip
					st_d = page.at('#new-form-prop > div > div.tender > p:nth-child(4) > em > span:nth-child(1)').text.strip
					en_d = page.at('#new-form-prop > div > div.tender > p:nth-child(4) > em > span:nth-child(3)').text.strip
					begin
						st_d = DateTime.parse( "#{st_d} +0400" ).to_time
					rescue ArgumentError
						st_d = ""
					end
					begin
						en_d = DateTime.parse( "#{en_d} +0400" ).to_time
					rescue ArgumentError
						en_d = ""
					end
					info = page.xpath('//*[@id="formMain:opStepValue"]').text.strip
					Interval.create(
						start_date: st_d,
						end_date:   en_d,
						price:      price,
						info:       info,
						lot_id:     lot.id
						)
				# если в федресурсе лот есть, а на площадке его нету
				# обработка ошибки не найденого элемента
				rescue Watir::Exception::UnknownObjectException
					Log.error "Данные не получены, пропуск\n"
					          "\turl: #{pbrw.url}" +
					          "\tNo.: #{params[:trade_number]}"
				rescue NoMethodError
					Log.error "Данные не получены, пропуск\n"
					          "\turl: #{pbrw.url}" +
					          "\tNo.: #{params[:trade_number]}"
				rescue Net::ReadTimeout
					Log.error "Истекло время ожидания при подключении, пропуск\n" +
					          "\turl: #{pbrw.url}" +
					          "\tNo.: #{params[:trade_number]}"
				end

		# end of class << self
		end

	# end of PlatformRules module
	end

# end of main module
end

