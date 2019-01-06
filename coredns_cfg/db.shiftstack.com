$ORIGIN shiftstack.com.
@       3600 IN SOA sns.dns.icann.org. noc.dns.icann.org. (
                                2017042745 ; serial
                                7200       ; refresh (2 hours)
                                3600       ; retry (1 hour)
                                1209600    ; expire (2 weeks)
                                3600       ; minimum (1 hour)
                                )
#ostest-master-0 IN A 10.0.0.223
ostest-etcd-2.shiftstack.com.     IN   CNAME        ostest-master-2
ostest-etcd-1.shiftstack.com.     IN   CNAME        ostest-master-1
ostest-etcd-0.shiftstack.com.     IN   CNAME        ostest-master-0
_etcd-server-ssl._tcp.ostest.shiftstack.com.  8640  IN      SRV         0     10 2380  ostest-etcd-0
_etcd-server-ssl._tcp.ostest.shiftstack.com.  8640  IN      SRV         0     10 2380  ostest-etcd-1
_etcd-server-ssl._tcp.ostest.shiftstack.com.  8640  IN      SRV         0     10 2380  ostest-etcd-2

