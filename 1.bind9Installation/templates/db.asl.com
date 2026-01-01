;
; BIND data file for local loopback interface
;
$TTL	604800
@	IN	SOA	asl.com. root.asl.com. (
			 xxxxxxxxxx	; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;
@	IN	NS	asl.cns.
@	IN	A	192.168.100.24

dns IN  A   192.168.100.24
