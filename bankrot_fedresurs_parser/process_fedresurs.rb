# coding: utf-8

####
##    process_fedresurs.rb
###
#

# парсинг основы bankrot.fedresurs.ru

# методы этого раздела в логах имеют префикс [fedresurs]

module BankrotFedresursParser

	# класс содержит методы обработки основы
	module Fedresurs

		# инициализация
		def self.init
			Log.dbg "process_fedresurs > init"
			### увеличение таймаута ожидания
			client = Selenium::WebDriver::Remote::Http::Default.new
			client.timeout = 180 # seconds – default is 30

			@@brw = Watir::Browser.new :firefox, http_client: client
		end

		# погнали типа
		def self.process!
			Log.dbg "process_fedresurs > process!"
			Log.info "[fedresurs] Ok, Let's go"
			loop_by_regions
			@@brw.close
		#rescue Watir::Exception::UnknownObjectException
    #	Log.error "ресурс не доступен"
    # @@brw.close
    #rescue Selenium::WebDriver::Error::ElementNotVisibleError
    #	Log.error "ресурс выдаёт ошибки"
    # @@brw.close
		end

		class << self

			# подключение общих
			include Shared

			# исключение не поддерживаемых площадок
			include PlatformsList

			#
			private
				# посещение основной страницы
				def vizit_fedresurs
					Log.dbg "process_fedresurs > vizit_fedresurs"
					@@brw.goto CFG.fedresurs_url
				end

				# заполнение формы и переход
				def fill_form
					Log.dbg "process_fedresurs > fill_form"
					# текущая дата
					# Формат: 20.05.2014 (ну или 01.01.2014 - в начале нолик)
					current_date = (Date.today - 1).to_time
					# установка вида торгов
					l =-> do
						@@brw.select_list(name: 'ctl00$cphBody$ucTradeType$ddlBoundList').select_value( CFG.vid_torgov )
						# начальная дата
						# TODO: поменять значение даты на нормальное
						@@brw.text_field(name: 'ctl00$cphBody$cldrBeginDate$tbSelectedDate').set( current_date ) # current_date ) #
						# поджиг onchange в обязаловку - ибо силами js значение копируется в скрытое поле, по событию
						@@brw.text_field(name: 'ctl00$cphBody$cldrBeginDate$tbSelectedDate').fire_event 'onchange'
						# конечная дата
						@@brw.text_field(name: 'ctl00$cphBody$cldrEndDate$tbSelectedDate').set( current_date ) #current_date)
						@@brw.text_field(name: 'ctl00$cphBody$cldrEndDate$tbSelectedDate').fire_event 'onchange'
					end
					l.call()
				rescue Watir::Exception::UnknownObjectException
					begin
						Log.warn "Федресурс неадекватит, попытка номер 2, url: #{@@brw.url}"
						sleep 30
						vizit_fedresurs
						l.call()
					rescue Watir::Exception::UnknownObjectException
						Log.error "Федресурс не дступен, или в неадеквте, не могу продолжить парсинг, url: #{@@brw.url}"
						Log.dbg "Выход"
						@@brw.close
						HEADLESS.destroy
						exit(1)
					end
				end

				# перебор регионов ( дабы не парсить все )
				def loop_by_regions
					Log.dbg "process_fedresurs > loop_by_regions"

					Geo.regions_ary.each do |r|
						Log.dbg "process_fedresurs > loop_by_regions > each"
						Log.info "регион: #{r[0]} | #{r[1]}"

						# дя каждого региона переход на основу и заполнение формы
						wait_timeout( CFG.links_follow_timeout )
						vizit_fedresurs
						fill_form

						wait_timeout CFG.form_timeout
						# выбор региона в поле
						@@brw.select_list(name: 'ctl00$cphBody$ucRegion$ddlBoundList').select_value( r[0] )
						# щелчёк по кнопке
						@@brw.button(name: 'ctl00$cphBody$btnTradeSearch').click
						# изменения
						wait_when_dom_changed @@brw.element( id: 'ctl00_cphBody_gvTradeList' )
						# полученую страницу передаём дальше
						process_paggination
						## метод выше прыгает по ссылками
						## выполняет много различных переходов
						## но в итоге для следующего региона
						## необходимо снова вернуться на федресурс
					# end of each
					end
				# end of def
				end

				# обработка пагинации ( постраничного вывода )
				def process_paggination
					Log.dbg "process_fedresurs > process_paggination"
					# цикл постраницам
					loop do
						# берём страницу
						page = Nokogiri::HTML( @@brw.html ) #.force_encoding('utf-8') ) # в utf-8 - это обязательно
						# и проверяем её
						if check_page( page )
							Log.dbg "process_fedresurs > process_paggination > if"
							# если проверка успешна, то
	
							# получение ссылок из таблички
							look_over_table( page )
	
							# переходн на следёющую страницу ( пагинация )
							break unless find_next_page( page )
						else
							# если заисей нет - то цикл разрывается
							break
						end
					# end of loop
					end
				end

				# проверка страницы на адекватность (а не бутор)
				def check_page page
					Log.dbg "process_fedresurs > check_page"
					# селектор антибот сообщения
					antibot_sel = 'div#ctl00_cphBody_upTradeList > span#ctl00_cphBody_antiBot_MessageLabel'
					# селектор шапки таблицы - это успешный выхлоп
					success_sel = 'table#ctl00_cphBody_gvTradeList > tbody > tr > th'
					# проверка на сообщение о частых запросах
					unless ( msg = page.css( antibot_sel ) ).empty?
						Log.error "[fedresurs] Запросы к 'fedresurs' посылаются слишком часто, сработала анти-бот защита\n" +
						          "\tСообщение: #{msg.text}"
						fail # экцепшн
					end

					# отладка
					#binding.pry

					# проверка на отсутствие результатов запроса
					#("По заданным критериям не найдено ни одной записи. Уточните критерии поиска")
					if ( msg = page.css( success_sel ) ).empty?
						Log.info "[fedresurs] На сегодня записей не найдено\n"
					           "\tСообщение: #{msg.text}"
						return false
					end
					# проверка присутствия таблицы с торгами
					unless page.css( success_sel ).empty?
						Log.success "[fedresurs] Обнаружен список торгов"
						return true 
					end
					# вариант не учитывающий вышепредложенные предпологает фиксы/патчи
					# вероятен по X причинам, и при смене движка fedresurs'а
					Log.error "[fedresurs] Дальнейшие действия не определены, при обработке страницы\n" +
					          "\tне обнаружен список торгов, но он не пуст и отсутствует сообщение об ошибке\n" +
					          "\tвероятно требуется переработка кода (или заглушка этого сообщения - ах-ха-ха)"
					fail # поджтг экцепшна - чтобы разработчик не прошёл мимо
				end

				# поиск необходимой информации в таблице
				def look_over_table( page )
					Log.dbg "process_fedresurs > look_over_table"
					tr_ary = page.css('table#ctl00_cphBody_gvTradeList > tbody > tr') # ctl00_cphBody_gvTradeList
					tr_ary.shift # fuck up th
					tr_ary.pop if tr_ary.last.attr(:class) == 'pager' # fuck it down

					# отладка
					#binding.pry

					tr_ary.each do |tr|
						Log.dbg "process_fedresurs > look_over_table > each by tr"
						td_ary = tr.css('td')
						#unless have_card?( td_ary )
							# пропус поиска адреса для не поддерживаемой площадки
							#begin
							Log.dbg "process_fedresurs > look_over_table > each by tr - grab platform_id from link href"
							platform_id = td_ary[3].css('a').first.attr(:href)
							#	rescue
							#		binding.pry
							#end
							Log.dbg "process_fedresurs > look_over_table > each by tr - gsub platform_id"
							platform_id = platform_id.gsub('/TradePlaceCard.aspx?ID=','').to_i
							Log.dbg "process_fedresurs > look_over_table > each by tr - check if able?"
							unless able?( platform_id )
								Log.warn "площадка #{platform_id} не поддерживается, пропуск"
								next
							end
							# проверка удалёности
							Log.dbg "process_fedresurs > look_over_table > each by tr - check: is so far?"
							next unless check_addres( td_ary )

							# формирование хеша с параметрами
							# хеш с параметрами или false
							Log.dbg "process_fedresurs > look_over_table > each by tr - get params call"
							platform_params =
												PlatformsParams.get_params_by_row( td_ary, platform_id )

							 if platform_params
							 	Log.dbg "process_fedresurs > look_over_table > each by tr - params present"
								# открываем новое окно браузера
								# площадка целиком в нём
								wait_timeout( CFG.links_follow_timeout )
								Log.dbg "process_fedresurs > look_over_table > each by tr - open new window for platform #{platform_params[:url]}"
								@@brw.execute_script("window.open(\"#{platform_params[:url]}\")")
								#
								Log.dbg "process_fedresurs > look_over_table > each by tr - switch to new window"
								@@brw.windows.last.use do
									# передача обработчику площадок
									Log.dbg "process_fedresurs > look_over_table > each by tr - new window > Platfor.process! call"
									Platforms.process!( platform_params, @@brw )
									#
									Log.dbg "process_fedresurs > look_over_table > each by tr - new window > close"
									@@brw.window.close rescue nil
									Log.dbg "process_fedresurs > look_over_table > each by tr - switch to previous window"
									@@brw.windows.last.use
								end
							end

					# end of each
					end
				end

				# а есть ли у должника карточка на федресурсе
				def have_card? td_ary
					Log.dbg "process_fedresurs > have_card?"

					# отладка
					#binding.pry

					!td_ary[4].css('a').empty?
				end

				# если у должника нет карточки - то грабим адрес по инн
				# с проверкой инн на адекватность (10 цифр)
				def grab_addres_by_inn td_ary
					Log.dbg "process_fedresurs > grab_addres_by_inn"

					addr = ""
					Log.dbg "process_fedresurs > grab_addres_by_inn > store wnd handler"
					handler = @@brw.driver.window_handle

					wait_timeout( CFG.links_follow_timeout )
					# переход по ссылке "публичное предложение" к информации
					wait_when_dom_changed( @@brw.body )
					Log.dbg "process_fedresurs > grab_addres_by_inn > open new window by link"
					@@brw.link( :href, td_ary[5].css('a').first.attr(:href) ).click :shift
					# новое окно, его и используем
					Log.dbg "process_fedresurs > grab_addres_by_inn > use new window"
					@@brw.windows.last.use do

						Log.dbg "process_fedresurs > grab_addres_by_inn > @@brw.winidows.last.use"

						inn = 0

						tbl = 'ctl00_cphBody_UpdatePanel4'

						# ЬИ
						wait_when_dom_changed( @@brw.element( id: tbl ) )

						# клик по "Сообщения"
						wait_timeout( CFG.links_follow_timeout )
						Log.dbg "process_fedresurs > grab_addres_by_inn > new window > click on 'сообщения'"
						@@brw.element( id: tbl ).element( id: 'ctl00_cphBody_rtsTrade' ).ul.lis[1].a.click
						# ожидание
						wait_when_dom_changed( @@brw.element( id: tbl ) )

						wait_timeout( CFG.links_follow_timeout )
						# клик по заявке
						Log.dbg "process_fedresurs > grab_addres_by_inn > new window > click and new window (inn page)"
						@@brw.element( id: tbl ).table( id: 'ctl00_cphBody_gvMessages' ).trs.last.tds.last.a.click
						# открывается новое окно - его используем
						Log.dbg "process_fedresurs > grab_addres_by_inn > new window > new new window use"
						@@brw.windows.last.use do

							Log.dbg "process_fedresurs > grab_addres_by_inn > @@brw.winidows.last.use > @@brw.winidows.last.use"

							Log.dbg "process_fedresurs > grab_addres_by_inn > @@brw.winidows.last.use > @@brw.winidows.last.use > grab inn"
							inn = @@brw.td(text: 'ИНН').parent.tds.last.text.strip

							# 10 - юрики
							# 12 - физики
							Log.dbg "process_fedresurs > grab_addres_by_inn > @@brw.winidows.last.use > @@brw.winidows.last.use > check inn size"
							if ( ![10,12].include?(inn.size) ) || inn == '0000000000' || inn == '000000000000'
								Log.warn "Фейковый должник (ИНН: #{inn}) - пропуск..."
								# отладка
								#binding.pry

								Log.dbg "process_fedresurs > grab_addres_by_inn > @@brw.winidows.last.use > @@brw.winidows.last.use - close"
								@@brw.window.close rescue nil
								Log.dbg "process_fedresurs > grab_addres_by_inn > @@brw.winidows.last.use > switch to previous wnd"
								@@brw.windows.last.use
								Log.dbg "process_fedresurs > grab_addres_by_inn > @@brw.winidows.last.use - close"
								@@brw.window.close rescue nil
								Log.dbg "process_fedresurs > grab_addres_by_inn > return false"
								return false
							end

							# отладка
							#binding.pry

							# инн получен, закываем окно нах
							# close
							Log.dbg "process_fedresurs > grab_addres_by_inn > @@brw.winidows.last.use - close"
							@@brw.window.close rescue nil
						end

						# возвращаемся к окну
						Log.dbg "process_fedresurs > grab_addres_by_inn > @@brw.winidows.last.use > switch to previous wnd"
						@@brw.windows.last.use

						wait_timeout( CFG.links_follow_timeout )
						# переход к списку организаций
						Log.dbg "process_fedresurs > grab_addres_by_inn > @@brw.winidows.last.use > goto 'DebtorsSearch'"
						@@brw.goto( 'http://bankrot.fedresurs.ru/DebtorsSearch.aspx' )

						#binding.pry
						#
						begin
							Log.dbg "process_fedresurs > grab_addres_by_inn > @@brw.winidows.last.use > case inn by size"
							case inn.size
							when 10
								Log.dbg "process_fedresurs > grab_addres_by_inn > @@brw.winidows.last.use > case inn by size: 10, set radio"
								@@brw.radio( name: 'ctl00$cphBody$rblDebtorType', value: 'Organizations' ).set
								Log.dbg "process_fedresurs > grab_addres_by_inn > @@brw.winidows.last.use > case inn by size: 10, set text_field"
								@@brw.text_field( name: 'ctl00$cphBody$OrganizationCode1$CodeTextBox' ).set( inn )
							when 12
								Log.dbg "process_fedresurs > grab_addres_by_inn > @@brw.winidows.last.use > case inn by size: 12, set radio"
								@@brw.radio( name: 'ctl00$cphBody$rblDebtorType', value: 'Persons' ).set
#								@@brw.wait_until { @@brw.text_field( name: 'ctl00$cphBody$PersonCode1$CodeTextBox' ).visible? }
								Log.dbg "process_fedresurs > grab_addres_by_inn > @@brw.winidows.last.use > case inn by size: 12, set text_field"
								@@brw.text_field( name: 'ctl00$cphBody$PersonCode1$CodeTextBox' ).set( inn )
							end
						rescue Selenium::WebDriver::Error::ElementNotVisibleError
							Log.dbg "process_fedresurs > grab_addres_by_inn > @@brw.winidows.last.use > rescue Selenium::WebDriver::Error::ElementNotVisibleError, close wnd, return false"
							@@brw.window.close rescue nil
							return false
						end
						#@@brw.wait_until { @@brw.text_field( name: 'ctl00$cphBody$OrganizationCode1$CodeTextBox' ).visible? }

						wait_timeout( CFG.form_timeout )
						Log.dbg "process_fedresurs > grab_addres_by_inn > @@brw.winidows.last.use > click to search"
						@@brw.button(name: 'ctl00$cphBody$btnSearch').click
						wait_when_dom_changed( @@brw.element(id: 'ctl00_cphBody_gvDebtors') )

						if @@brw.element( id: 'ctl00_cphBody_gvDebtors' ).text.strip ==
												'По заданным критериям не найдено ни одной записи. Уточните критерии поиска'
							Log.warn "Должник не зарегистрирован - пропуск..."
							Log.dbg "process_fedresurs > grab_addres_by_inn > @@brw.winidows.last.use > debtor not found, close wnd, return false"
							@@brw.window.close rescue nil
							return false
						end

						Log.dbg "process_fedresurs > grab_addres_by_inn > @@brw.winidows.last.use > grab addr"
						addr =
							@@brw.table(
								id: 'ctl00_cphBody_gvDebtors'
								).trs[1].tds[5].text.strip

						# отладка
						#binding.pry

						# закрытие окна
						Log.dbg "process_fedresurs > grab_addres_by_inn > @@brw.winidows.last.use - close"
						@@brw.window.close rescue nil
					end
					Log.dbg "process_fedresurs > grab_addres_by_inn > return addr"
					return addr
				rescue Watir::Exception::UnknownObjectException
					Log.dbg "process_fedresurs > grab_addres_by_inn > rescue Watir::Exception::UnknownObjectException"
					# тупняк сайта
					Log.dbg "process_fedresurs > grab_addres_by_inn > rescue Watir::Exception::UnknownObjectException > each by wnd handlers"
					@@brw.driver.window_handles.each do |h|
						Log.dbg "process_fedresurs > grab_addres_by_inn > rescue Watir::Exception::UnknownObjectException > each - switch"
						@@brw.driver.switch_to.window( h )
						unless h == handler
							Log.dbg "process_fedresurs > grab_addres_by_inn > rescue Watir::Exception::UnknownObjectException > each - close"
							@@brw.window.close rescue nil
						end
					end
					Log.dbg "process_fedresurs > grab_addres_by_inn > rescue Watir::Exception::UnknownObjectException > switch to first hndler"
					@@brw.driver.switch_to.window( handler )
					Log.dbg "process_fedresurs > grab_addres_by_inn > rescue Watir::Exception::UnknownObjectException > return ''"
					return ''
				end

				# получение адреса из карточки
				def grab_addres_by_card td_ary
					Log.dbg "process_fedresurs > grab_addres_by_card"
					# результат
					addr = ""
					# переход к карточке должника ( в новом окне )
					Log.dbg "process_fedresurs > grab_addres_by_card > new wnd by click link"
					@@brw.link( :href, td_ary[4].css('a').first.attr(:href) ).click :shift
					# обработка нового окна и его закрытие
					Log.dbg "process_fedresurs > grab_addres_by_card > switch to new wnd"
					@@brw.windows.last.use do
						begin
							l =-> do
								Log.dbg "process_fedresurs > grab_addres_by_card > @@brw.windows.last.use do"

								# отладка
								#binding.pry
								wait_when_dom_changed( @@brw.body )
								Log.dbg "process_fedresurs > grab_addres_by_card > @@brw.windows.last.use do > grab addr"
								addr = @@brw.element( id: "ctl00_cphBody_trAddress").tds[1].text.strip
								# закроем новое окно
								Log.dbg "process_fedresurs > grab_addres_by_card > @@brw.windows.last.use do - close"
								@@brw.window.close rescue nil
							end

							l.call()
						rescue Watir::Wait::TimeoutError
							# истекло время ожидания смены DOM
							Log.warn "Истекло время ожидания, попытка номер два:"
							begin
								sleep 30
								l.call()
								rescue Watir::Wait::TimeoutError
									Log.error "Истекло время ожидания при подключении, пропуск"
									@@brw.window.close rescue nil
									return ""
							end
						end
					end
					addr
				rescue Watir::Exception::UnknownObjectException
					Log.dbg "process_fedresurs > grab_addres_by_card > Watir::Exception::UnknownObjectException, return ''"
					Log.warn "Не удалось получить адрес, вероятно ошибка на федресурсе, опять он тупит, пропуск"
					# если федресурс тупит
					return ""
				end

				# проверим адрес должника - не далеко ли он?
				def check_addres td_ary
					Log.dbg "process_fedresurs > check_addres"

					Log.dbg "process_fedresurs > check_addres > pull addr"
					addr = have_card?( td_ary ) ?
						grab_addres_by_card( td_ary ) : grab_addres_by_inn( td_ary )

					# если вместо адреса ложь - то её и возвращаем
					Log.dbg "process_fedresurs > check_addres > return addr unless addr?"
					return addr unless addr
					Log.dbg "process_fedresurs > check_addres > Geo.near? #{addr}"
					Geo.near? addr
				end

				# поиск следующей страницы ( пагинация ) и переход на неё
				def find_next_page( page )
					Log.dbg "process_fedresurs > find_next_page"
					# Если элемент присутствует - значит пагинация возможна
					sel = 'table#ctl00_cphBody_gvTradeList tr.pager'

					# отладка
					#binding.pry

					if ( pg = page.css( sel ) ).empty?
						Log.info "[fedresurs] Обработка пагинации: всего одна страница, пагинации нету."
						return false
					end
					# в итоге примерно будет так
					# pg.css('table td span').first.parent.next.css('a').first[:href]
					# текущая страница?
					Log.info "[fedresurs] Обработка пагинации: текущая страница" +
					         " No. #{pg.css('table td span').first.text}"
					nxt = pg.css('table td span').first.parent.next.css('a')
					if nxt.empty?
						Log.info "[fedresurs] Обработка пагинации: это последняя страница"
						return false
					end
					# Переход на следующую
					Log.info "[fedresurs] Обработка пагинации: перход на страницу No. #{nxt.first.text}"
					# где-то тут, чтоле, должен быть учёт частоты посылаемых запросов при пагинации
					wait_timeout( CFG.links_follow_timeout )
					Log.dbg "process_fedresurs > find_next_page > execute_script(__doPostBack...)"
					begin
						@@brw.execute_script("__doPostBack('ctl00$cphBody$gvTradeList','Page$#{nxt.first.text.strip}')")
					rescue Selenium::WebDriver::Error::JavascriptError
						# если федресурс неадекватит и скрипт не был загружен
						Log.warn "Федресурс неадекватит, не могу перелистнуть страницу, пропуск"
						return false
					end
					begin
						wait_when_dom_changed @@brw.element( id: 'ctl00_cphBody_gvTradeList' )
					rescue Watir::Exception::UnknownObjectException
						Log.error 'Какая-то ошибка на федресурсе'
						Log.dbg "process_fedresurs > find_next_page > Watir::Exception::UnknownObjectException, return false"
						return false
					end
					true
				end

			# end of private

		# end of class << self
		end

	# end of Fedresurs module
	end

# end of main module
end
