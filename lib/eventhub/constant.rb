module EventHub

	EVENT_HUB_QUEUE_INBOUND = 'inbound'
						
	STATUS_INITIAL 					= 0         # initial status code
	STATUS_SUCCESS 					= 200       # compare with HTTP Status Code: Success
	STATUS_RETRIED 					= 300       # compare with HTTP Status Code: Multiple Choices
	STATUS_INVALID					= 400       # compare with HTTP Status Code: Bad request
	STATUS_UNDELIVERABLE 		= 500  			# comapre with HTTP Status Code: Server Error

end