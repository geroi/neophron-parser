# coding: utf-8

#sqlite.rb

require 'sqlite3'
require 'active_record'

# обёртка

module BankrotFedresursParser

	ActiveRecord::Base.establish_connection(
  	  adapter: "sqlite3",
    	database: CFG.db_file
	)

	unless File.exist?( CFG.db_file )
		ActiveRecord::Schema.define do
	    	create_table :intervals do |t|
	      	  t.integer  :lot_id
	      	  t.datetime :start_date
	      	  t.datetime :end_date
	 				  t.integer  :reduction # снижение
	 				  t.string   :deposit   # задаток
	          t.integer  :price     # цена на интервале
	          t.text     :info      # информация по снижению цены
	          t.timestamps
	  	  end
	
	    	create_table :platforms do |t|
	      	  t.integer :number
	      	  t.timestamps
	  	  end
	
	    	create_table :lots do |t|
	      	  t.integer :platform_id
	      	  t.string  :url
	      	  t.text    :subject
	      	  t.text    :description
	      	  t.timestamps
	  	  end
		end
	end

	class Interval < ActiveRecord::Base

		# оцифровка
		before_validation do
			# .gsub(/,.*/,'').gsub(/\W+/,'_').to_i
			self.reduction = reduction_before_type_cast.gsub(/,.*/,'').gsub(/\..*/,'').gsub(/\W+/,'_').to_i if attribute_present?("reduction")
			self.deposit = deposit_before_type_cast.gsub(/,.*/,'').gsub(/\..*/,'').gsub(/\W+/,'_').to_i if attribute_present?("deposit")
			self.price = price_before_type_cast.gsub(/,.*/,'').gsub(/\..*/,'').gsub(/\W+/,'_').to_i if attribute_present?("price")
		end

		belongs_to :lot
	end

	class Platform < ActiveRecord::Base
		has_many :lots

		def self.find_or_create_by_number number
			unless ( pl = Platform.where( number: number ).take )
				pl = Platform.create( number: number )
			end
			pl
		end

	end

	class Lot < ActiveRecord::Base
		has_many :intervals
		belongs_to :platform

		def self.find_or_create_by_url url
			unless ( lot = Lot.where( url: url ).take )
				lot = Lot.create( url: url )
			end
			lot
		end

	end

end




