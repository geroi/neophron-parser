# coding: utf-8

####
##    platforms_list.rb
###
#

# список торговых площадок в виде массива хэшей:
# [ id => { name: '...', url: '..' }, ... ]


module BankrotFedresursParser

	module PlatformsList

		LIST = {
				# id площадки на федресурсе
			  179 => {
			  		# название площадки
			      name: 'Ru-Trade24',
			      # url площадки
			      url: 'http://www.ru-trade24.ru/',
			      # доступна ли обработка данной площадки?
			      able: false,
			      # информация по, для вывода в лог
			      info: "Алгоритм обработки площадки не определён",
			      # заметки для разработчика, в логах не указываются, присутствуют только здесь
			      note: "Заметок нет",
			      # вариант алгоритма обработки площадки, дата его написания или правки
			      algo: "03.06.2014",
			      # стратегия обработки
			      type: :ru_trade24
			    },
			  175 => {
			      name: 'Агентство правовых коммуникаций',
			      url: 'http://www.apktorgi.ru/etp/trade/list.html',
			      able: true,
			      info: "Алгоритм обработки площадки определён но не проверен",
			      note: "На площадке нет ни одного торга, посмотреть скелет страницы не представляется возможным",
			      algo: "03.06.2014",
			      type: :type1
			    },
			  182 => {
			      name: 'АИСТ',
			      url: 'http://aistorg.ru/',
			      able: false,
			      info: "Алгоритм обработки площадки не определён, не удавалось перейти на площадку",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :unknown
			    },
			  139 => {
			      name: 'Арбитат',
			      url: 'http://www.arbitat.ru/public/public-offers/',
			      able: true,
			      info: "Алгоритм обработки площадки определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type2
			    },
			  177 => {
			      name: 'АрбиТрейд',
			      url: 'http://arbitrade.ru/',
			      able: false,
			      info: "Алгоритм обработки площадки не определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :arbitrade
			    },
			  181 => {
			      name: 'Банкротство РТ',
			      url: 'http://etp-bankrotstvo.ru/public/public-offers-all/',
			      able: true,
			      info: "Алгоритм обработки площадки определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type2
			    },
			  168 => {
			      name: 'Всероссийская Электронная Торговая Площадка',
			      url: 'http://xn-----6kcbaifbn4di5abenic8aq7kvd6a.xn--p1ai/etp/trade/list.html',
			      able: true,
			      info: "Алгоритм обработки площадки не определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type1
			    },
			  120 => {
			      name: 'Межотраслевая торговая система "Фабрикант',
			      url: 'http://www.fabrikant.ru/',
			      able: true,
			      info: "Алгоритм обработки площадки не определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :fabrikant
			    },
			  176 => {
			      name: 'Межрегиональная Торговая Система',
			      url: 'http://mts-etp.ru/public/public-offers-all/',
			      able: true,
			      info: "Алгоритм обработки площадки определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type2
			    },
			  143 => {
			      name: 'МФБ',
			      url: 'http://etp.mse.ru/etp/trade/list.html',
			      able: true,
			      info: "Алгоритм обработки площадки не определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type1
			    },
			  173 => {
			      name: 'Общероссийская система электронной торговли',
			      url: 'http://www.zakazrf.ru/NotificationEA/NotificationEAList.aspx',
			      able: false,
			      info: "Алгоритм обработки площадки не определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :zakazrf
			    },
			  180 => {
			      name: 'Открытая торговая площадка',
			      url: 'http://www.opentp.ru/public/public-offers-all/',
			      able: true,
			      info: "Алгоритм обработки площадки определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type2
			    },
			  174 => {
			      name: 'ЭТП "Агенда',
			      url: 'http://bankrupt.etp-agenda.ru/public/public-offers-all/',
			      able: true,
			      info: "Алгоритм обработки площадки определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type2
			    },
			  167 => {
			      name: 'ЭТС24',
			      url: 'https://ets24.ru/index.php?class=Auction&action=List&AuctionType=Bankrupt',
			      able: false,
			      info: "Алгоритм обработки площадки не определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :ets24
			    },
			  137 => {
			      name: 'Property Trade',
			      url: 'http://www.propertytrade.ru/public/public-offers-all/',
			      able: true,
			      info: "Алгоритм обработки площадки определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type2
			    },
			  131 => {
			      name: 'RUSSIA OnLine',
			      url: 'http://www.rus-on.ru/trades',
			      able: false,
			      info: "Алгоритм обработки площадки не определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :rus_on
			    },
			  166 => {
			      name: 'Новые информационные сервисы',
			      url: 'http://nistp.ru/etp/trade/list.html',
			      able: true,
			      info: "Алгоритм обработки площадки определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type1
			    },
			  136 => {
			      name: 'Региональная Торговая площадка',
			      url: 'http://www.regtorg.com/etp/trade/list.html',
			      able: true,
			      info: "Алгоритм обработки площадки не определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type1 # trunc
			    },
			  128 => {
			      name: 'Системы ЭЛектронных Торгов',
			      url: 'http://selt-online.ru/',
			      able: false,
			      info: "Алгоритм обработки площадки не определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :selt_online
			    },
			  146 => {
			      name: 'ТЕНДЕР ГАРАНТ',
			      url: 'http://www.tendergarant.com/',
			      able: true,
			      info: "Алгоритм обработки площадки определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type2
			    },
			  150 => {
			      name: 'Электрон-Март',
			      url: 'http://electronmart.ru/',
			      able: false,
			      info: "Алгоритм обработки площадки не определён, не удавалось перейти на площадку",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :undefined
			    },
			  138 => {
			      name: 'Электронная площадка «Вердиктъ',
			      url: 'http://www.vertrades.ru/bankrupt/public/public-offers-all/',
			      able: true,
			      info: "Алгоритм обработки площадки определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type2
			    },
			  129 => {
			      name: 'Электронная торговая площадка ELECTRO-TORGI.RU',
			      url: 'http://bankrupt.electro-torgi.ru/public/public-offers-all/',
			      able: true,
			      info: "Алгоритм обработки площадки определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type2
			    },
			  119 => {
			      name: 'B2B-Center',
			      url: 'http://www.b2b-center.ru/market/',
			      able: true,
			      info: "Алгоритм обработки площадки определён",
			      note: "Заметок нет",
			      algo: "07.06.2014",
			      type: :b2b_center
			    },
			  133 => {
			      name: 'KARTOTEKA.RU',
			      url: 'http://etp.kartoteka.ru/public/public-offers-all/',
			      able: true,
			      info: "Алгоритм обработки площадки определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type2
			    },
			  154 => {
			      name: 'UralBidIn',
			      url: 'http://www.uralbidin.ru/public/public-offers-all/',
			      able: true,
			      info: "Алгоритм обработки площадки определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type2
			    },
			  109 => {
			      name: 'uTender',
			      url: 'http://utender.ru/public/public-offers-all/',
			      able: true,
			      info: "Алгоритм обработки площадки определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type2
			    },
			  142 => {
			      name: 'АКОСТА info',
			      url: 'http://www.akosta.info/etp/trade/list.html',
			      able: true,
			      info: "Алгоритм обработки площадки не определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type1 # trunc
			    },
			  157 => {
			      name: 'Альфалот',
			      url: 'http://www.alfalot.ru/public/public-offers/',
			      able: true,
			      info: "Алгоритм обработки площадки определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type2
			    },
			  145 => {
			      name: 'Аукцион-центр',
			      url: 'http://www.aukcioncenter.ru/etp/trade/list.html',
			      able: false,
			      info: "Алгоритм обработки площадки не определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :aukcioncenter
			    },
			  159 => {
			      name: 'Аукционы Дальнего Востока',
			      url: 'http://www.torgidv.ru/etp/trade/list.html',
			      able: true,
			      info: "Алгоритм обработки площадки не определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type1 # trunc
			    },
			  132 => {
			      name: 'Балтийская электронная площадка',
			      url: 'http://www.bepspb.ru/public/public-offers-all/',
			      able: true,
			      info: "Алгоритм обработки площадки определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type2
			    },
			  169 => {
			      name: 'Бизнес-Групп',
			      url: 'http://bg-tender.ru/public/public-offers/',
			      able: true,
			      info: "Алгоритм обработки площадки определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type2
			    },
			  163 => {
			      name: 'Владимирский Тендерный Центр',
			      url: 'http://etp33.ru/etp/trade/list.html',
			      able: true,
			      info: "Алгоритм обработки площадки не определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type1
			    },
			  170 => {
			      name: 'Евразийская торговая площадка',
			      url: 'http://eurtp.ru/Home/PublicOffering',
			      able: false,
			      info: "Алгоритм обработки площадки не определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :eurtp
			    },
			  152 => {
			      name: 'Единая торговая электронная площадка',
			      url: 'http://tender-ug.ru/',
			      able: false,
			      info: "Алгоритм обработки площадки не определён, не удавалось перейти на площадку",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :undefined
			    },
			  121 => {
			      name: 'ЗАО «Сбербанк-АСТ»',
			      url: 'http://utp.sberbank-ast.ru/Bankruptcy/List/BidList',
			      able: true,
			      info: "Алгоритм обработки площадки определён",
			      note: "Заметок нет",
			      algo: "09.06.2014",
			      type: :sberbank_ast
			    },
			  178 => {
			      name: 'Межрегиональная Электронная Торговая Площадка',
			      url: 'http://www.m-etp.ru/public/public-offers/',
			      able: true,
			      info: "Алгоритм обработки площадки определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type2
			    },
			  127 => {
			      name: 'Межрегиональная Электронная Торговая Система',
			      url: 'http://www.m-ets.ru/search',
			      able: true,
			      info: "Алгоритм обработки площадки определён",
			      note: "Заметок нет",
			      algo: "08.06.2014",
			      type: :m_ets
			    },
			  140 => {
			      name: 'МЕТА-ИНВЕСТ',
			      url: 'http://www.meta-invest.ru/public/public-offers/',
			      able: true,
			      info: "Алгоритм обработки площадки определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type2
			    },
			  165 => {
			      name: 'Объединенная Торговая Площадка',
			      url: 'http://utpl.ru/public/public-offers/',
			      able: true,
			      info: "Алгоритм обработки площадки определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type2
			    },
			  161 => {
			      name: 'ООО «Специализированная организация по проведению торгов – Южная Электронная Торговая Площадка»',
			      url: 'http://torgibankrot.ru/public/public-offers-all/',
			      able: true,
			      info: "Алгоритм обработки площадки определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type2
			    },
			  156 => {
			      name: 'РИД',
			      url: 'http://ridtorg.ru/public/public-offers/',
			      able: true,
			      info: "Алгоритм обработки площадки определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type2
			    },
			  124 => {
			      name: 'Российский аукционный дом',
			      url: 'http://bankruptcy.lot-online.ru/e-auction/lots.xhtml',
			      able: true,
			      info: "Алгоритм обработки площадки не определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :lot_online # fucking
			    },
			  135 => {
			      name: 'Сибирская торговая площадка',
			      url: 'http://www.sibtoptrade.ru/bankruptcy/',
			      able: true,
			      info: "Алгоритм обработки площадки определён",
			      note: "Постфикс /closed для url, для закрытых торгов, но на них срать",
			      algo: "03.06.2014",
			      type: :sibtoptrade # fucking, so fucking stiupid!!! and fucking! and stiupid
			    },
			  160 => {
			      name: 'Система электронных торгов и муниципальных аукционов "ВТБ-Центр"',
			      url: 'http://vtb-center.ru/etp/trade/list.html',
			      able: true,
			      info: "Алгоритм обработки площадки не определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type1 # trunc
			    },
			  158 => {
			      name: 'ТендерСтандарт',
			      url: 'http://www.tenderstandart.ru/public/public-offers/',
			      able: true,
			      info: "Алгоритм обработки площадки определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type2
			    },
			  162 => {
			      name: 'Уральская электронная торговая площадка',
			      url: 'http://bankrupt.etpu.ru/public/public-offers-all/',
			      able: true,
			      info: "Алгоритм обработки площадки определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type2
			    },
			  141 => {
			      name: 'Центр дистанционных торгов',
			      url: 'http://cdtrf.ru/public/undef/card/tradel.aspx',
			      able: true,
			      info: "Алгоритм обработки площадки определён",
			      note: "Заметок нет",
			      algo: "09.06.2014",
			      type: :cdtrf
			    },
			  126 => {
			      name: 'Электронная площадка "Аукционный тендерный центр"',
			      url: 'http://www.atctrade.ru/etp/trade/list.html',
			      able: true,
			      info: "Алгоритм обработки площадки определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type1
			    },
			  123 => {
			      name: 'Электронная площадка "Аукционы Сибири"',
			      url: 'http://www.ausib.ru/etp/trade/list.html',
			      able: true,
			      info: "Алгоритм обработки площадки не определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type1
			    },
			  125 => {
			      name: 'Электронная площадка "Система Электронных Торгов Имуществом" (СЭЛТИМ)',
			      url: 'http://www.seltim.ru/etp/trade/list.html',
			      able: true,
			      info: "Алгоритм обработки площадки не определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type1 # trunc
			    },
			  153 => {
			      name: 'Электронная площадка "Электронные системы Поволжья"',
			      url: 'http://el-torg.com/publics',
			      able: true,
			      info: "Алгоритм обработки площадки определён",
			      note: "Заметок нет",
			      algo: "09-.06.2014",
			      type: :el_torg
			    },
			  155 => {
			      name: 'Электронная площадка №1',
			      url: 'http://www.etp1.ru/public/public-offers/',
			      able: true,
			      info: "Алгоритм обработки площадки определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type2
			    },
			  164 => {
			      name: 'Электронная площадка Группы компаний ВИТ',
			      url: 'http://etp.vitnw.ru/etp/trade/list.html',
			      able: true,
			      info: "Алгоритм обработки площадки не определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type1 # trunc
			    },
			  122 => {
			      name: 'Электронная площадка Центра реализации',
			      url: 'http://www.bankrupt.centerr.ru/public/public-offers-all/',
			      able: true,
			      info: "Алгоритм обработки площадки определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type2
			    },
			  171 => {
			      name: 'Электронная Торговая Площадка "ПОВОЛЖСКИЙ АУКЦИОННЫЙ ДОМ"',
			      url: 'http://auction63.ru/',
			      able: false,
			      info: "Алгоритм обработки площадки не определён, не удавалось перейти на площадку",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :undefined
			    },
			  149 => {
			      name: 'Электронная торговая площадка "Профит"',
			      url: 'http://www.etp-profit.ru/etp/trade/list.html',
			      able: true,
			      info: "Алгоритм обработки площадки не определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type1
			    },
			  151 => {
			      name: 'Электронная торговая площадка "Регион"',
			      url: 'http://gloriaservice.ru/public/public-offers-all/',
			      able: true,
			      info: "Алгоритм обработки площадки определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type2
			    },
			  172 => {
			      name: 'Электронная торговая площадка "ЮНИТРЕЙД"',
			      url: 'http://www.electrontorg.ru/',
			      able: false,
			      info: "Алгоритм обработки площадки не определён, не удавалось перейти на площадку",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :undefined
			    },
			  130 => {
			      name: 'Электронная торговая площадка «Торговая Интеграционная Система Тендер»',
			      url: 'http://tis-tender.ru/',
			      able: false,
			      info: "Алгоритм обработки площадки не определён, не удавалось перейти на площадку",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :undefined
			    },
			  144 => {
			      name: 'Электронный капитал',
			      url: 'http://www.eksystems.ru/etp/trade/list.html?type=bankruptcySales',
			      able: true,
			      info: "Алгоритм обработки площадки не определён",
			      note: "Заметок нет",
			      algo: "03.06.2014",
			      type: :type1
			    }
		}

		def url_by_id( id )
			LIST[ id ][ :url ]
		end

		def name_by_id( id )
			LIST[ id ][ :name ]
		end

		def able?( id )
			Log.dbg "platforms_list > able? No: #{id}"
			check_list(id) ? LIST[ id ][ :able ] : false
		end

		def strategy_by_id( id )
			LIST[ id ][ :type ]
		end

		def check_list( id )
			if LIST[ id ].nil?
				Log.error "В списке отсутствует площадка номер #{id}"
				false
			else
				true
			end
		end

	end

end
