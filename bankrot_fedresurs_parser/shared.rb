# coding: utf-8

####
##    shared.rb
###
#

### общие вспомогательные методы

module BankrotFedresursParser

	module Shared

		# логи методов этого раздела имеют префикс [shared]
	
		# перед выполнением блока добавляет задержку timeout, с
		def wait_timeout( timeout, &blk )
			Log.dbg "shared > wait_timeout, timeout: #{timeout}"

			timeout.times do |i|
				Log.live_update "[shared] задержка #{timeout - i}c "
				sleep 1
			end

			print "\r" + " "*34
			print "\r"

			yield if block_given?

		end

		# ожидание изменений в DOM
		def wait_when_dom_changed element, &blk
				element.when_dom_changed do
					Log.dbg "shared > wait_when_dom_changed"
					yield if block_given?
				end
			rescue Watir::Exception::UnknownObjectException
				sleep 1
				element.when_dom_changed do
					Log.dbg "shared > wait_when_dom_changed !!!rescue"
					yield if block_given?
				end
		end

		### drft
		#### в новом окне с последующим закрытием
		###def open_new_window( opener, brw, &blk )
		###	brw.
		###end

	# end of Shared module
	end

# end of main module
end


