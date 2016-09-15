# coding: utf-8

# reporter.rb

module BankrotFedresursParser
	module Reporter
		def self.process!
			time = Time.now.strftime('%H-%M_%d-%h-%Y')
			send_report time, genrated_report( time )
		end

		class << self
			private
				def genrated_report time
					report =<<-EOF
To: kashmatov@mail.ru\nFrom: reporter\nSubject: Report on #{Time.now.to_s}\nMime-version: 1.0\nContent-type: text/html; charset=utf-8\n\n
<html>
  <head>
    <meta charset='utf-8' />
    <title>Отчёт на #{time}</title>
    <style type='text/css'>
    .main td{
    	border: 1px solid #aaa;
    	vertical-align: top;
    }
    .main th{
    	background-color: #ccc;
    }
    .reduce{
    	width: 100%;
    }
    </style>
  </head>
  <body>
    <table class='main'>
      <caption>Отчёт на #{time}</caption>
      <tr>
        <th>Лот</th>
        <th>Описание</th>
        <th>Ссылка</th>
        <th>Информация по снижению цены</th>
EOF
					coll = Lot.where( updated_at: START_TIME..Time.now )
					coll.each do |l|
						report += "<tr>\n<td>"
						report += "#{l.subject}" unless l.subject.nil?
						report += "</td>\n<td>"
						report += "#{l.description}" unless l.description.nil?
						report += "</td>\n<td>"
						report += "<a href='#{l.url}'>линк</a>"
						report += "</td>\n<td class='reduce_td'>"
						report += "<table class='reduce'>\n"
						unless l.intervals.first.nil? or l.intervals.first.info.nil?
							report += "<tr>\n"
							report += "<th>Информация по снижению цены</th>" unless l.intervals.first.info.nil?
							report += "<th>Задаток</th>" unless l.intervals.first.deposit.nil?
							report += "<th>Цена</th>" unless l.intervals.first.price.nil?
							report += "<th>Начало торгов</th>" unless l.intervals.first.start_date.nil?
							report += "<th>Окончание торгов</th>" unless l.intervals.first.end_date.nil?
							report += "\n</tr>\n<tr>\n"
							report += "<td>#{l.intervals.first.info}</td>\n" unless l.intervals.first.info.nil?
							report += "<td>#{l.intervals.first.deposit}</td>\n" unless l.intervals.first.deposit.nil?
							report += "<td>#{l.intervals.first.price}</td>\n" unless l.intervals.first.price.nil?
							report += "<td>#{l.intervals.first.start_date.localtime.to_s[1..-7]}</td>\n" unless l.intervals.first.start_date.nil?
							report += "<td>#{l.intervals.first.end_date.localtime.to_s[1..-7]}</td>\n" unless l.intervals.first.end_date.nil?
							report += "\n</tr>\n"
						else
							report += "<tr>\n"
							report += "<th>начало</th>\n"
							report += "<th>окончание</th>\n"
							report += "<th>задаток</th>\n"
							report += "<th>цена</th>\n"
							report += "</tr>\n"
							l.intervals.each do |i|
								report += "<tr>\n"
								report += "<td>"
								report += "#{i.start_date.localtime.to_s[1..-7]}" unless i.start_date.nil?
								report += "</td>\n"
								report += "<td>"
								report += "#{i.end_date.localtime.to_s[1..-7]}" unless i.end_date.nil?
								report += "</td>\n"
								report += "<td>#{i.deposit}</td>\n"
								report += "<td>#{i.price}</td>\n"
								report += "</tr>\n"
							end
						end
						report += "</table>\n"
						report += "</td>\n</tr>"
					end
					report += "</table>\n</body>\n</html>"
				end

				def send_report time, message
					return( Log.info("Записей нет, на сегодня") ) if message == ''
					file = "./reports/#{time}.html"
					File.open( file,'w'){ |f| f.puts( message ) }
					`ssmtp #{CFG.report_email} < #{file}`
				end

		end
	end
end