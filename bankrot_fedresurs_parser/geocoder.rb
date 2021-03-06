# coding: utf-8

####
##    geocoder.rb
###
#

# всё касаемо расстояний/адресов/регионов здесь

require 'russian'
require 'geocoder'

module BankrotFedresursParser

	# лог-префикс для этого раздела [geo]

	# немножечко не законченно,
	# в идеале было бы неплохо изолировать Geocoder
	# в пространстве имён модуля BankrotFedresursParser
	# на случай совместного использования этого гема с
	# чем-нибудь другим использующим Geocoder.
	# Во избежании возможных конфликтов.
	# Пока не знаю как это замутить и это печально

	#
	module Geo

		Geocoder.configure lookup: :yandex, units: :km

		def self.near?( addr )
			Log.dbg "geocoder > near?"
			Log.dbg "\tarrd: #{addr}"
			return true if distance( addr ) <= CFG.max_distance
			Log.dbg "\tso far"
			false
		end

		## массив с регионами для просмотра по ним
		## ясен перец, что Владивосток далековато
		#
		# этот метод полностью функционален для Москвы,
		# но при смене домашней точки или расширении области поиска
		# требует модернизации
		#
		def self.regions_ary
			[	
				[ '45', 'Москва' 								],
				[ '46', 'Московская область' 		],
				[ '29', 'Калужская область' 		],
				[ '66', 'Смоленская область' 		],
				[ '28', 'Тверская область' 			],
				[ '78', 'Ярославская область' 	],
				[ '17', 'Владимирская область' 	],
				[ '61', 'Рязанская область' 		],
				[ '70', 'Тульская область' 			]
			]
		end

		class << self
			private
				def distance addr
					d = Geocoder::Calculations.distance_between(
						Geocoder.coordinates( Russian.translit( addr ) ),
						CFG.home_geolocation )
					d.nan? ? 20000 : d.round
				end
		end

	end

end

###
##   Черновые наброски, на случай расширения области поиска или смены домашней точки
###

#[ 79  , "Адыгея (республика)" 				]
#[ 84  , "Алтай (республика)" 				]
#[ 1   , "Алтайский край" 					]
#[ 10  , "Амурская область" 					]
#[ 11  , "Архангельская область" 			]
#[ 12  , "Астраханская область" 				]
#[ 80  , "Башкортостан (республика)" 		]
#[ 14  , "Белгородская область" 				]
#[ 15  , "Брянская область" 					]
#[ 81  , "Бурятия (республика)" 				]
#[ 17  , "Владимирская область" 				]
#[ 18  , "Волгоградская область" 			]
#[ 19  , "Вологодская область" 				]
#[ 20  , "Воронежская область" 				]
#[ 82  , "Дагестан (республика)" 			]
#[ 99  , "Еврейская АО" 						]
#[ 101 , "Забайкальский край" 				]
#[ 24  , "Ивановская область" 				]
#[ 26  , "Ингушетия (республика)" 			]
#[ 25  , "Иркутская область" 				]
#[ 83  , "Кабардино-Балкарская республика" 	]
#[ 27  , "Калининградская область" 			]
#[ 85  , "Калмыкия (республика)" 			]
#[ 29  , "Калужская область" 				]
#[ 30  , "Камчатский край" 					]
#[ 91  , "Карачаево-Черкесская республика" 	]
#[ 86  , "Карелия (республика)" 				]
#[ 32  , "Кемеровская область" 				]
#[ 33  , "Кировская область" 				]
#[ 87  , "Коми (республика)" 				]
#[ 34  , "Костромская область" 				]
#[ 3   , "Краснодарский край" 				]
#[ 4   , "Красноярский край" 				]
#[ 202 , "Крым (республика)" 				]
#[ 37  , "Курганская область" 				]
#[ 38  , "Курская область" 					]
#[ 41  , "Ленинградская область" 			]
#[ 42  , "Липецкая область" 					]
#[ 44  , "Магаданская область" 				]
#[ 88  , "Марий-эл (республика)" 			]
#[ 89  , "Мордовия (республика)" 			]
#[ 45  , "Москва" 							]
#[ 46  , "Московская область" 				]
#[ 47  , "Мурманская область" 				]
#[ 200 , "Ненецкий автономный округ" 		]
#[ 22  , "Нижегородская область" 			]
#[ 49  , "Новгородская область" 				]
#[ 50  , "Новосибирская область" 			]
#[ 52  , "Омская область" 					]
#[ 53  , "Оренбургская область" 				]
#[ 54  , "Орловская область" 				]
#[ 56  , "Пензенская область" 				]
#[ 57  , "Пермский край" 					]
#[ 5   , "Приморский край" 					]
#[ 58  , "Псковская область" 				]
#[ 102 , "Республика Северная Осетия-Алания" ]
#[ 60  , "Ростовская область" 				]
#[ 61  , "Рязанская область" 				]
#[ 36  , "Самарская область" 				]
#[ 40  , "Санкт-Петербург" 					]
#[ 63  , "Саратовская область" 				]
#[ 64  , "Сахалинская область" 				]
#[ 65  , "Свердловская область" 				]
#[ 201 , "Севастополь" 						]
#[ 66  , "Смоленская область" 				]
#[ 7   , "Ставропольский край" 				]
#[ 68  , "Тамбовская область" 				]
#[ 92  , "Татарстан  (республика)" 			]
#[ 28  , "Тверская область" 					]
#[ 69  , "Томская область" 					]
#[ 93  , "Тува  (республика)" 				]
#[ 70  , "Тульская область" 					]
#[ 71  , "Тюменская область" 				]
#[ 94  , "Удмуртская Республика" 			]
#[ 73  , "Ульяновская область" 				]
#[ 8   , "Хабаровский край" 					]
#[ 95  , "Хакасия  (республика)" 			]
#[ 103 , "Ханты-Мансийский автономный округ" ]
#[ 75  , "Челябинская область" 				]
#[ 96  , "Чеченская Республика" 				]
#[ 76  , "Читинская область" 				]
#[ 97  , "Чувашская республика" 				]
#[ 77  , "Чукотский АО" 						]
#[ 98  , "Якутия-Саха  (республика)" 		]
#[ 104 , "Ямало-Ненецкий автономный округ" 	]
#[ 78  , "Ярославская область" 				]
