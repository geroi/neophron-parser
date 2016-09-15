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
				# sber
				def sberbank_ast params, pbrw
					Log.dbg "sber id: #{params[:id]}, trade_number: #{params[:trade_number]}"
					# итак в параметрах уже есть всё необходимое
					# браузер открыт на нужной странице,
					# поехали

					# fill form
					Log.dbg "sber fill text_field"
					pbrw.text_field(id: 'tbxPurchaseCode').set( params[:trade_number] )
					wait_timeout( CFG.links_follow_timeout )
					Log.dbg "sber click search"
					pbrw.button(id: 'btnSearch').click
					#
					wait_timeout( CFG.links_follow_timeout )
					Log.dbg "sber click link (follow first result)"
					pbrw.element(css: '#tbl > tbody > tr > td:nth-child(2) > a').click

					pbrw.tbody(id: 'tblBidsbody').trs.size.times do |i|
						wait_timeout( CFG.links_follow_timeout )
						begin
							pbrw.tbody(id: 'tblBidsbody').trs[i].tds[1].a.click
							wait_when_dom_changed( pbrw.body )
						rescue Selenium::WebDriver::Error::StaleElementReferenceError
							Log.dbg "sber > each > rescue Selenium::WebDriver::Error::StaleElementReferenceError, next"
							### ожидание и возврат к списку
							wait_timeout( CFG.links_follow_timeout )
							pbrw.back
							next
						end
						### stuff here
						# ноко
						page = Nokogiri::HTML( pbrw.html )
						subject = page.at('#DynamicControlPurchaseinfo_PurchaseName').text.strip
						description = page.at('#DynamicControlBidInfo_DebtorBidName').text.strip
						#dep = page.at('#DynamicControlBidInfo_BidDeposit').text.strip[/\d+/] + "%"
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
						#reduction
						reduction =	page.at('#tblBidReductionPeriodbody').css('tr')
						st_d, en_d = nil
						reduction.each do |tr|
							#
							begin
								st_d = DateTime.parse( "#{tr.css('td')[1].text.strip} +0400" ).to_time
							rescue ArgumentError
								st_d = ""
							end
							begin
								en_d = DateTime.parse( "#{tr.css('td')[2].text.strip} +0400" ).to_time
							rescue ArgumentError
								en_d = ""
							end
							price = tr.css('td')[3].text.strip
							dep  = tr.css('td')[4].text.strip
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
						### ожидание и возврат к списку
						wait_timeout( CFG.links_follow_timeout )
						pbrw.back
						### end
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
				# end of sber
				end

				# эль_торг
				def el_torg params, pbrw
					Log.dbg "el_torg id: #{params[:id]}, trade_number: #{params[:trade_number]}"
					# итак в параметрах уже есть всё необходимое
					# браузер открыт на нужной странице,
					# поехали

					# fill form
					pbrw.text_field(name: 'field_zayavka_au_ca_pp_numerator_value').set( params[:trade_number] )
					wait_timeout( CFG.links_follow_timeout )
					pbrw.button(id: 'edit-submit-auction-lots').click

					pbrw.tbody(css: '#art-main > div.art-sheet > div.art-sheet-body > div.art-content-layout > div > div.art-layout-cell.art-content > div > div > div > div.art-postcontent > div > div.view-content > table > tbody').trs.each do |tr|
						wait_timeout( CFG.links_follow_timeout )
						tr.tds[2].a.click :shift
						pbrw.windows.last.use do
							### stuff here
							# ноко
							page = Nokogiri::HTML( pbrw.html )
							subject = page.at('div > div > div > div > div.field.art-postcontent > div > div > a').text.strip
							description = page.at('div > div > div > div > div:nth-child(2) > div > div.field.field-type-text.field-field-lot-description > div > div').text.strip.gsub("\n",' ')
							lot = Lot.find_or_create_by_url( pbrw.url )
							lot.update_attributes(
								subject:     subject,
								description: description,
								platform_id: Platform.find_or_create_by_number( params[:id] ).id
								)
										Log.success "Лот\n" +
													"\tнаименование: #{subject}\n" +
													"\tописание    : #{description}\n" +
													"\turl:          #{pbrw.url}"
										#reduction
							reduction =	page.at('#art-main > div.art-sheet > div.art-sheet-body > div.art-content-layout > div > div.art-layout-cell.art-content > div > div > div.panels-flexible-row.panels-flexible-row-41-1.panels-flexible-row-last.clear-block > div > div > div > div > div > div > div.rounded-shadow-left-edge > div > div.panel-pane.pane-views.pane-intervals-for-lot-pp > div > div > div > table > tbody').css('tr')
							reduction.each do |tr|
								#
								begin
									st_d = DateTime.parse( "#{tr.css('td')[1].text.strip} +0400" ).to_time
								rescue ArgumentError
									st_d = ""
								end
								begin
									en_d = DateTime.parse( "#{tr.css('td')[2].text.strip} +0400" ).to_time
								rescue ArgumentError
									en_d = ""
								end
								price = tr.css('td')[5].text.strip
								dep  = tr.css('td')[4].text.strip
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
							### end
						# закрытие новых окон
							# закрытие текущего
							pbrw.window.close rescue nil
							# переход к предыдущему
							pbrw.windows.last.use
						# window
						end
					# each
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
				# end of el_torg
				end


				# cdtrf
				def cdtrf params, pbrw
					Log.dbg "cdtrf id: #{params[:id]}, trade_number: #{params[:trade_number]}"
					# итак в параметрах уже есть всё необходимое
					# браузер открыт на нужной странице,
					# поехали

					# goto
					wait_timeout( CFG.links_follow_timeout )
					pbrw.goto "http://cdtrf.ru/public/undef/card/trade.aspx?id=#{params[:trade_number]}"
					#
					### stuff here
					# ноко
					page = Nokogiri::HTML( pbrw.html )
					subject = page.at('#ctl00_cph1_lName').text.strip
					description = page.at('#ctl00_cph1_lLotInfo').text.strip
					lot = Lot.find_or_create_by_url( pbrw.url )
					lot.update_attributes(
						subject:     subject,
						description: description,
						platform_id: Platform.find_or_create_by_number( params[:id] ).id
						)
					Log.success "Лот\n" +
											"\tнаименование: #{subject}\n" +
											"\tописание    : #{description}\n" +
											"\turl:          #{pbrw.url}"
					#reduction
					begin
						st_d = DateTime.parse( "#{page.at('#ctl00_cph1_lRequestTimeBegin').text.strip} +0400" ).to_time
					rescue ArgumentError
						st_d = ""
					end
					begin
						en_d = DateTime.parse( "#{page.at('#ctl00_cph1_lRequestTimeEnd').text.strip} +0400" ).to_time
					rescue ArgumentError
						en_d = ""
					end
					price = page.at('#ctl00_cph1_lPriceBegin').text.strip
					info = page.at('#ctl00_cph1_lDecreaseRules').text.strip
					dep  = "20%"
					#
					Interval.create(
						start_date: st_d,
						end_date:   en_d,
						price:      price,
						deposit:    dep,
						info:       info,
						lot_id:     lot.id
						)
					#
					Log.success "Интервал"
					Log.success "\tдата начала:    #{st_d}"  if st_d
			  	Log.success "\tдата окончания: #{en_d}"  if en_d
			  	Log.success "\tзадаток:        #{dep}"   if dep
			  	Log.success "\tцена:           #{price}" if price

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
				# end of cdtrf
				end


				# sibtoptrade
				def sibtoptrade params, pbrw
					Log.dbg "sibtoptrade id: #{params[:id]}, trade_number: #{params[:trade_number]}, debtor: #{params[:debtor]}"
					# итак в параметрах уже есть всё необходимое
					# браузер открыт на нужной странице,
					# поехали
					rx = /#{params[:debtor].gsub("\"",'').gsub("'",'').gsub("«",'').gsub("»",'')}/i
					# сделаем элемент видимым
					pbrw.execute_script("$('select[name=Debtor]').css('display','block')")
					wait_when_dom_changed( pbrw.element( css: '.content' ) )
					pbrw.select_list(:name => 'Debtor').select( rx )

					wait_timeout( CFG.links_follow_timeout )
					pbrw.button( value: 'Искать' ).click
					wait_timeout( CFG.links_follow_timeout )
					pbrw.element( css: 'body > div:nth-child(7) > div > div > table > tbody' ).trs( text: params[:trade_number] ).first.div.a.click
					#
					### stuff here
					# ноко
					page = Nokogiri::HTML( pbrw.html )
					subject = page.at('body > div > p:nth-child(23)').text.strip
					lot = Lot.find_or_create_by_url( pbrw.url )
					lot.update_attributes(
						subject:     subject,
						platform_id: Platform.find_or_create_by_number( params[:id] ).id
						)
					Log.success "Лот\n" +
											"\tнаименование: #{subject}\n" +
											"\turl:          #{pbrw.url}"
					#reduction
					price = page.at('body > div > table:nth-child(24) > tbody > tr:nth-child(2) > td:nth-child(2)').text.strip
					info = page.at('body > div > table:nth-child(24) > tbody > tr:nth-child(2) > td:nth-child(3)').text.strip
					#
					Interval.create(
						price:      price,
						info:       info,
						lot_id:     lot.id
						)
					#
					Log.success "Интервал"
			  	Log.success "\tцена:           #{price}" if price

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
				rescue Watir::Exception::NoValueFoundException
					Log.error "Данные не получены, пропуск\n"
					          "\turl: #{pbrw.url}" +
					          "\tNo.: #{params[:trade_number]}"
				rescue Net::ReadTimeout
					Log.error "Истекло время ожидания при подключении, пропуск\n" +
					          "\turl: #{pbrw.url}" +
					          "\tNo.: #{params[:trade_number]}"
				# end of sibtoptrade
				end

		# end of class << self
		end

	# end of PlatformRules module
	end

# end of main module
end

