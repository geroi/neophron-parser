# coding: utf-8

####
##    platforms_rules.rb
###
#

require 'open-uri'

# правила для обработки площадок type1 и type2

module BankrotFedresursParser

	module PlatformsRules

		# ноко хелпер
		class RegexHelper
			def content_matches_regex node_set, regex_string
				! node_set.select { |node| node.content =~ /#{regex_string}/i }.empty?
			end
		end

		# частная территория
		class << self
			#
			include Shared

			#
			private
				#
				def type2 params, pbrw
					Log.dbg "type2 id: #{params[:id]}, pp_num: #{params[:pp_num]}, lot_num: #{params[:lot_num]}"
					# итак в параметрах уже есть всё необходимое
					# браузер открыт на нужной странице,
					# поехали
					pbrw.text_field(
						name: 'ctl00$ctl00$MainExpandableArea$phExpandCollapse$ctl00$SearchCriteria1$vPurchaseLot_purchaseNumber_публичногопредложения'
						).set( params[:pp_num] )
					pbrw.text_field(
						name: 'ctl00$ctl00$MainExpandableArea$phExpandCollapse$ctl00$SearchCriteria1$vPurchaseLot_lotNumber_лота'
						).set( params[:lot_num] )
					# все
					pbrw.select(
						name:
						  'ctl00$ctl00$MainExpandableArea$phExpandCollapse$ctl00$SearchCriteria1$vPurchaseLot_purchaseStatusID_Статус'
						  ).select(/все/i)
					#
					pbrw.button( name: 'ctl00$ctl00$MainExpandableArea$phExpandCollapse$ctl00$btnSearch' ).click
					wait_when_dom_changed pbrw.element( id: 'ctl00_ctl00_MainContent_ContentPlaceHolderMiddle_ctl00_SearchResult2' )
					# do
					wait_timeout( CFG.links_follow_timeout ) do
						pbrw.element( 
							css: '#ctl00_ctl00_MainContent_ContentPlaceHolderMiddle_ctl00_SearchResult2 > tbody > tr.gridRow > td:nth-child(4) > a'
							).click
						wait_when_dom_changed pbrw.body
					end
					# end

					# 1
					tr_ary = pbrw.table(
					  id: 'ctl00$ctl00$MainContent$ContentPlaceHolderMiddle$ctl00$vcPurchaseLot'
					  ).trs
					# 2
					description = nil
					# each
					tr_ary.each do |tr|
						description = tr.tds[3].text.strip if tr.text.match /сведения об/i
					# end of each
					end
					# 2.1
					Log.success "Лот"
					Log.success "\tнаименование: #{subject = tr_ary[1].tds[1].text.strip}"
					Log.success "\tсведения:     #{description}"
					Log.success "\turl:          #{url = pbrw.url}"
					# 3
					lot = Lot.find_or_create_by_url( url )
					# 4
					lot.update_attributes(
						subject: subject,
						description: description,
						platform_id: Platform.find_or_create_by_number( params[:id] ).id
						)
					# 5
					tr_ary = pbrw.table(
					  id: 'ctl00_ctl00_MainContent_ContentPlaceHolderMiddle_ctl00_publicOfferReduction_srPublicOfferReductionPeriod'
					  ).tbody.trs
					# 6
					indexes = { st_d: false, en_d: false, reduce: false, dep: false, price: false }
					# 7
					# each
					tr_ary[0].tds.each_with_index do |td,i|
					  indexes[:st_d] = i if td.text.match /дата начала приема заявок на интервале/i
					  indexes[:en_d] = i if td.text.match /дата окончания приема заявок на интервале/i
					  indexes[:reduce] = i if td.text.match /снижение цены/i
					  indexes[:dep] = i if td.text.match /задаток/i
					  indexes[:price] = i if td.text.match /цена/i
					# end of each
					end
					# 8
					# each_with_index
					tr_ary.each_with_index do |tr,i|
					  next if i == 0
					  begin
					  	st_d   = DateTime.parse( "#{tr.tds[ indexes[:st_d] ].text.strip} +0400" ).to_time
					  rescue ArgumentError
							st_d = ""
						end
						begin
					  	en_d   = DateTime.parse( "#{tr.tds[ indexes[:en_d] ].text.strip} +0400" ).to_time
					  rescue ArgumentError
							en_d = ""
						end
					  reduce = tr.tds[ indexes[:reduce] ].text.strip if indexes[:reduce]
					  dep    = tr.tds[ indexes[:dep] ].text.strip if indexes[:dep]
					  price  = tr.tds[ indexes[:price] ].text.strip
					  Log.success "Интервал"
					  Log.success "\tдата начала:    #{st_d}"
					  Log.success "\tдата окончания: #{en_d}"
					  Log.success "\tснижение:       #{reduce}"
					  Log.success "\tзадаток:        #{dep}"
					  Log.success "\tцена:           #{price}"
					  Interval.create(
					  	start_date: st_d,
					  	end_date:   en_d,
					  	price:      price,
					  	deposit:    dep,
					  	reduction:  reduce,
					  	lot_id: lot.id
					  	)
					# end of each_with_index
					end

				# если в федресурсе лот есть, а на площадке его нету
				# обработка ошибки не найденого элемента
				rescue Watir::Exception::UnknownObjectException
					Log.error "Данные не получены, пропуск\n"
					          "\turl:     #{pbrw.url}" +
					          "\tNo.ПП:   #{params[:pp_num]}" +
					          "\tNo.Лота: #{params[:lot_num]}"
				rescue NoMethodError
					Log.error "Данные не получены, пропуск\n"
					          "\turl: #{pbrw.url}" +
					          "\tNo.ПП:   #{params[:pp_num]}" +
					          "\tNo.Лота: #{params[:lot_num]}"
				rescue Net::ReadTimeout
					Log.error "Истекло время ожидания при подключении, пропуск\n" +
										"\turl: #{pbrw.url}" +
					          "\tNo.ПП:   #{params[:pp_num]}" +
					          "\tNo.Лота: #{params[:lot_num]}"
				# end of type2
				end

				# m_ets is type1 fork
				def m_ets params, pbrw
					Log.dbg "m_est id: #{params[:id]}, trade_number: #{params[:trade_number]}"
					# итак в параметрах уже есть всё необходимое
					# браузер открыт на нужной странице,
					# поехали

					# смена
					wait_timeout( CFG.links_follow_timeout )
					pbrw.goto "http://www.m-ets.ru/search?lots=&r_num=#{ URI.escape( params[:trade_number] ) }"
					wait_when_dom_changed pbrw.body
					##
					# do
					wait_timeout( CFG.links_follow_timeout )

					pbrw.a(css: 'table.commontable:nth-child(5) > tbody:nth-child(2) > tr:nth-child(1) > td:nth-child(2) > a:nth-child(1)').click

					##

					# ноко
					page = Nokogiri::HTML( pbrw.html )
					# st_d, en_d
					st_d = page.at('#content > table:nth-child(7) > tbody > tr:nth-child(27) > td:nth-child(2)').text.strip
					en_d = page.at('#content > table:nth-child(7) > tbody > tr:nth-child(28) > td:nth-child(2)').text.strip
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
					#
					lots = page.css('#content > table > tbody > tr > th[content_matches_regex("\W*сведения\W+по\W+лоту\W+№\d+\W*")]',RegexHelper.new)
					#
					lots.each do |lt|
						tds, subject, description, price, info = nil
						tds = lt.parent.parent.css('td')
						subject = tds[3].text.strip
						description = tds[5].text.strip
						price = tds[9].text.strip
						dep = tds[11].text.strip
						info = tds[13].text.strip
						lot = Lot.find_or_create_by_url( pbrw.url )
						lot.update_attributes(
							subject: subject,
							description: description,
							platform_id: Platform.find_or_create_by_number( params[:id] ).id
							)
						Log.success "Лот"
						Log.success "\tнаименование: #{subject}"
						Log.success "\tсведения:     #{description}"
						Log.success "\turl:          #{pbrw.url}"
						Interval.create(
							start_date: st_d,
							end_date:   en_d,
							price:      price,
							deposit:    dep,
							info:       info,
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
				# end of m_ets
				end


				# type1 & type1 trunc
				def type1 params, pbrw
					Log.dbg "type2 id: #{params[:id]}, trade_number: #{params[:trade_number]}"
					# итак в параметрах уже есть всё необходимое
					# браузер открыт на нужной странице,
					# поехали
					pbrw.text_field(
						name: 'number'
						).set( params[:trade_number] )
					#
					pbrw.button( name: 'eventSubmit_doList' ).click
					wait_when_dom_changed pbrw.body
					# do
					wait_timeout( CFG.links_follow_timeout )
					pbrw.table(
						class: 'data'
						).trs[1].tds[2].element( css: '*' ).click
					##

					# ноко
					page = Nokogiri::HTML( pbrw.html )
					# st_d, en_d
					st_d, en_d = nil
					#
					tbl = (
						page.css(
									'table.data > tbody > tr > th[content_matches_regex("\W*(сведения|информация)\W+о\W+(процедуре\W+торгов|торгах)\W*")]',
									RegexHelper.new
									).first.nil? ?
								page.css(
										'table.data > thead > tr > th[content_matches_regex("\W*(сведения|информация)\W+о\W+(процедуре\W+торгов|торгах)\W*")]',
										RegexHelper.new
										) :
								page.css(
										'table.data > tbody > tr > th[content_matches_regex("\W*(сведения|информация)\W+о\W+(процедуре\W+торгов|торгах)\W*")]',
										RegexHelper.new
										)
								).first.parent.parent.parent
					#
					# unless
					unless tbl.nil?
						st_d = (
							tbl.css(
								'tbody > tr[content_matches_regex("\W*начало\W+(приема|предоставления)\W+заявок\W+на\W+участие\W*")]',
								RegexHelper.new
								).first.nil? ?
								tbl.css(
									'thead > tr[content_matches_regex("\W*начало\W+(приема|предоставления)\W+заявок\W+на\W+участие\W*")]',
									RegexHelper.new
									) :
								tbl.css(
									'tbody > tr[content_matches_regex("\W*начало\W+(приема|предоставления)\W+заявок\W+на\W+участие\W*")]',
									RegexHelper.new
									)
								).first.css('td')[1].text.strip
						en_d = (
							tbl.css(
								'tbody > tr[content_matches_regex("\W*окончание\W+(приема|предоставления)\W+заявок\W+на\W+участие\W*")]',
								RegexHelper.new
								).first.nil? ?
								tbl.css(
									'thead > tr[content_matches_regex("\W*окончание\W+(приема|предоставления)\W+заявок\W+на\W+участие\W*")]',
									RegexHelper.new
									) :
								tbl.css(
									'tbody > tr[content_matches_regex("\W*окончание\W+(приема|предоставления)\W+заявок\W+на\W+участие\W*")]',
									RegexHelper.new
									)
								).first.css('td')[1].text.strip
					# end of unless
					end
					# вилка
					unless ( tbl = (
						page.css(
									'table.data > tbody > tr > th[content_matches_regex("\W*(сведения|информация)\W+о\W+предмете\W+торгов\W*")]',
									RegexHelper.new
									).first.nil? ?
								page.css(
										'table.data > thead > tr > th[content_matches_regex("\W*(сведения|информация)\W+о\W+предмете\W+торгов\W*")]',
										RegexHelper.new
										) :
								page.css(
										'table.data > tbody > tr > th[content_matches_regex("\W*(сведения|информация)\W+о\W+предмете\W+торгов\W*")]',
										RegexHelper.new
										)
						).first ).nil?
						# one lot
						tbl = tbl.parent.parent.parent
						#
						subject, description, price, dep, info = nil
						#
						# each_with_index
						tbl.css('tr').each_with_index do |tr,i|
							next if i == 0
							subject = tr.css('td')[1].text.strip unless (
								tr.css(
									'td[content_matches_regex("\W*предмет\W+торгов\W*")]',
									RegexHelper.new ).empty?
								)
							description = tr.css('td')[1].text.strip unless (
								tr.css(
									'td[content_matches_regex("\W*сведения\W+об\W+имуществе.*")]',
									RegexHelper.new ).empty?
								)
							price = tr.css('td')[1].text.strip unless (
								tr.css(
									'td[content_matches_regex("\W*начальная\W+цена.*")]',
									RegexHelper.new ).empty?
								)
							dep = tr.css('td')[1].text.strip unless (
								tr.css(
									'td[content_matches_regex("\W*размер\W+задатка.*")]',
									RegexHelper.new ).empty?
								)
							info = "порядок снижения цены: #{tr.css('td')[1].text.strip}" unless (
								tr.css(
									'td[content_matches_regex("\W*порядок\W+снижения\W+цены.*")]',
									RegexHelper.new ).empty?
								)
							en_d = tr.css('td')[1].text.strip unless (
								tr.css(
									'td[content_matches_regex("\W*дата\W+и\W+время\W+завершения.*")]',
									RegexHelper.new ).empty?
								)
							info = "величина повышения начальной цены: #{tr.css('td')[1].text.strip}" unless (
								tr.css(
									'td[content_matches_regex("\W*величина\W+повышения.*")]',
									RegexHelper.new ).empty?
								)
						# end of each_with_index
						end
							#
							url = pbrw.url
							#
							Log.success "Лот"
							Log.success "\tнаименование: #{subject}"
							Log.success "\tсведения:     #{description}"
							Log.success "\turl:          #{url}"
							# 3
							lot = Lot.find_or_create_by_url( url )
							# 4
							lot.update_attributes(
								subject: subject,
								description: description,
								platform_id: Platform.find_or_create_by_number( params[:id] ).id
								)
							# 5
							begin
								st_d   = DateTime.parse( "#{st_d} +0400" ).to_time
							rescue ArgumentError
								st_d = ""
							end
							begin
								en_d   = DateTime.parse( "#{en_d} +0400" ).to_time
							rescue ArgumentError
								en_d = ""
							end
							# 6
							Log.success "Интервал"
							Log.success "\tдата начала:    #{st_d}"  if st_d
					  	Log.success "\tдата окончания: #{en_d}"  if en_d
					  	Log.success "\tснижение:       #{info}"  if info
					  	Log.success "\tзадаток:        #{dep}"   if dep
					  	Log.success "\tцена:           #{price}" if price
					  	Interval.create(
					  		start_date: st_d,
					  		end_date:   en_d,
					  		price:      price,
					  		deposit:    dep,
					  		info:       info,
					  		lot_id:     lot.id
					  		)
					else
						# per lot
						(
							page.css(
							'table.data > tbody > tr > th[content_matches_regex("\W*лот\W+№\d+:.*")]',
							RegexHelper.new
							).first.nil? ?
								page.css(
								'table.data > thead > tr > th[content_matches_regex("\W*лот\W+№\d+:.*")]',
								RegexHelper.new
								) :
								page.css(
								'table.data > tbody > tr > th[content_matches_regex("\W*лот\W+№\d+:.*")]',
								RegexHelper.new
								)
						).each do |lt|
						# each
							tbl = lt.parent.parent.parent
							##################################################################
								#
								subject, description, price, dep, info = nil
								#
								subject = tbl.at('th').text.strip
								#
								# each_with_index
								tbl.css('tr').each_with_index do |tr,i|
									next if i == 0
									description = tr.css('td')[1].text.strip unless (
										tr.css(
											# на atctrade.ru аглицкая 'C' вместо руссуой 'С' в слове 'Сведения'
											#   - какой-то пидр делал походу,
											#   вероятно не только на этом сайте - пидры!!!
											'td[content_matches_regex("\W*(c|с)ведения\W+об\W+имуществе.*")]',
											RegexHelper.new ).empty?
										)
									price = tr.css('td')[1].text.strip unless (
										tr.css(
											'td[content_matches_regex("\W*начальная\W+цена.*")]',
											RegexHelper.new ).empty?
										)
									dep = tr.css('td')[1].text.strip unless (
										tr.css(
											'td[content_matches_regex("\W*размер\W+задатка.*")]',
											RegexHelper.new ).empty?
										)
									info = "порядок снижения цены: #{tr.css('td')[1].text.strip}" unless (
										tr.css(
											'td[content_matches_regex("\W*порядок\W+снижения\W+цены.*")]',
											RegexHelper.new ).empty?
										)
									en_d = tr.css('td')[1].text.strip unless (
										tr.css(
											'td[content_matches_regex("\W*дата\W+и\W+время\W+завершения.*")]',
											RegexHelper.new ).empty?
										)
									info = "величина повышения начальной цены: #{tr.css('td')[1].text.strip}" unless (
										tr.css(
											'td[content_matches_regex("\W*величина\W+повышения.*")]',
											RegexHelper.new ).empty?
										)
								# end of each_with_index
								end
									#
									url = pbrw.url
									#
									Log.success "Лот"
									Log.success "\tнаименование: #{subject}"
									Log.success "\tсведения:     #{description}"
									Log.success "\turl:          #{url}"
									# 3
									lot = Lot.find_or_create_by_url( url )
									# 4
									lot.update_attributes(
										subject: subject,
										description: description,
										platform_id: Platform.find_or_create_by_number( params[:id] ).id
										)
									# 5
									begin
										st_d   = DateTime.parse( "#{st_d} +0400" ).to_time
									rescue ArgumentError
										st_d = ""
									end
									begin
										en_d   = DateTime.parse( "#{en_d} +0400" ).to_time
									rescue ArgumentError
										en_d = ""
									end
									# 6
									Log.success "Интервал"
									Log.success "\tдата начала:    #{st_d}"  if st_d
							  	Log.success "\tдата окончания: #{en_d}"  if en_d
							  	Log.success "\tснижение:       #{info}"  if info
							  	Log.success "\tзадаток:        #{dep}"   if dep
							  	Log.success "\tцена:           #{price}" if price
							  	Interval.create(
							  		start_date: st_d,
							  		end_date:   en_d,
							  		price:      price,
							  		deposit:    dep,
							  		info:       info,
							  		lot_id:     lot.id
							  		)
							##################################################################
						# end of each
						end
					# end of unless-
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
				# end of type1
				end


		# end of class << self
		end

	# end of PlatformRules module
	end

# end of main module
end
