#By. L.M #Feat : lucas-TagDev , Hendson
#13/11/22
#Agent  monitoracao crontab para plataforma plesk
#Status = Homologação não utilizar em prod
#obs http://json2table.com/

description=$(plesk version | egrep "Plesk" | awk '{print $3, $4, $5}')

os=$(plesk version | grep "OS version:" | sed 's/ OS version: //g' | tr -d ' ')

license=$(plesk bin license -c) #Checa license Online

total_domains=$(plesk db -Ne "SELECT COUNT(*) FROM psa.domains WHERE parentDomainId = 0") #TOTAL de domains

hostname=$(hostname)


#ID DO SERVIDOR
#id=$'2'

#------------------------------------------------------------------------
#template de post
template='{"description":"%s", "os":"%s", "license":"%s", "total_domains":"%s", "hostname":"%s" }'

#template de post
json_string=$(printf "$template" "$description" "$os" "$license" "$total_domains"  "$hostname")

#----------------------------------------------------------------------

#PUT
#template='{"description":"%s", "os":"%s", "license":"%s", "total_domains":"%s", "hostname":"%s", "id":"%s" }'

#PUT
#json_string=$(printf "$template" "$description" "$os" "$license" "$total_domains"  "$hostname" "$id")




echo "$json_string"

curl -i \
-H "Accept: application/json" \
-H "Content-Type:application/json" \
-X POST --data "$json_string" "http://177.101.158.126:8080/tasks"
