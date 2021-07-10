#!/bin/bash
DOMAIN="client.com.au"                                                                                                       
echo "**************************************************************"                                                      
echo "Running host"    
echo "**************************************************************"    
host -a $DOMAIN                                                          
echo "**************************************************************"    
echo "DIG Results"                                                       
echo "**************************************************************"    
dig $DOMAIN any                                                                   
echo "**************************************************************"    
#Zone transfer test:                                               
#host -l $DOMAIN GTM1.$DOMAIN                                                                                              
#host -l $DOMAIN GTM2.$DOMAIN                                                                                              
#dig @gtm1.$DOMAIN $DOMAIN axfr                                                                                            
#dig @gtm2.$DOMAIN $DOMAIN axfr                                                                                            
#This comand tries the dns transfer and some additional attacks                                                            
echo "**************************************************************"                                                      
echo "DNS ENUM"                                                                                                            
echo "**************************************************************"                                                      
dnsenum $DOMAIN                                                                                                            
dnsrecon -d $DOMAIN                                                                                                        
echo "**************************************************************"                                                      
echo "FIERCE"                                                                                                              
echo "**************************************************************"                                                      
fierce --domain $DOMAIN                                                                                                    
echo "**************************************************************"                                                      
echo "DMITRY DNS ENUM"                                                                                                     
echo "**************************************************************"                                                      
#dnsdict6                                                                                                                  
dmitry -iwnse $DOMAIN                                                                                                      
echo "**************************************************************"      
echo "HACKER TARGET" 
echo "**************************************************************"                                                      
echo "Route"
curl https://api.hackertarget.com/mtr/?q=$DOMAIN
echo "Access to the on-line Test Ping API"
curl https://api.hackertarget.com/nping/?q=$DOMAIN
echo "Access to the DNS Lookup API"
curl https://api.hackertarget.com/dnslookup/?q=$DOMAIN
echo "Access to the Reverse DNS Lookup API"
curl https://api.hackertarget.com/reversedns/?q=$DOMAIN
echo "Access to the Whois Lookup API"
curl https://api.hackertarget.com/whois/?q=$DOMAIN
echo "Access to the GeoIP Lookup API"
curl https://api.hackertarget.com/geoip/?q=$DOMAIN
echo "Access to the Reverse IP Lookup API"
curl https://api.hackertarget.com/reverseiplookup/?q=$DOMAIN
echo "Access to the HTTP Headers API"
curl https://api.hackertarget.com/httpheaders/?q=www.$DOMAIN
echo "Access to the Page Links API"
curl https://api.hackertarget.com/pagelinks/?q=www.$DOMAIN
echo "Access to the AS Lookup API"
curl https://api.hackertarget.com/aslookup/?q=$DOMAIN
