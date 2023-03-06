#!/bin/bash

#Author : Luan F. 
#Ano: 2022
#Funcao : Gerar backup de  domains para pasta especifica do cliente  
#Execução : Agendar no cron ex: 
#cada 15 dias # 0 15 */15 * * /root/manual.sh > /root/logcron.txt 2>&1
#diario minuto e hora # 04 11 * * * /root/manual.sh > /root/logcron.txt 2>&1
#----------------------------------------------------------------------------------------------------
#IMPORTANTE ! JAMAIS UTILIZAR O MESMO DOMINIO DE DIRETORIO DE DESTINO QUE ESTEJA NA LISTA DOMAINS.TXT
#SEMPRE CRIAR UM DOMAIN APENAS PARA ARMAZENAR O BACKUP
#O MESMO DEVE SER AJUSTADO NA CONDIÇÃO #PREPARA LISTA (NOT LIKE)
#----------------------------------------------------------------------------------------------------
#REF : https://kb.resellerclub.com/article/Understanding-the-logs-Linux-Plesk-Panel-Logs-and-Locations
#Valide as permissões de diretório para nao ficar exposto na internet ex: rwx r-x r-- 

#Variaveis
DESTINO="/var/www/vhosts/seudominiodebackup.com.br/httpdocs/backup/BKP_CLIENTES/"
TEMP="/usr/local/psa/PMM/sessions/"
#LIMPA DIRETORIO DE DESTINO E NA SESSIONS PLESK  *REMOVE QUALQUER COISA NO DESTINO

echo "Iniciando a limpeza de espaço temp e destino" $(date +%F_%H:%M:%S)

 rm -rf $TEMP*
 rm -rf $DESTINO*

echo "Limpeza concluida" $(date +%F_%H:%M:%S)

#PREPARA LISTA DO BANCO EXCETO QUALQUER DOMAIN HOSPEDAGEMWEB.NET # comente a linha abaixo e crie um domain no arquivo para validar a rotina
 /sbin/plesk db -Ne "select name  from  domains where name NOT LIKE '%seudominiodebackup.com.br%'" > domains.txt

echo "Atualizada a lista de dominios para backup  com sucesso!" $(date +%F_%H:%M:%S)

#COMECA O BACKUP

for domain  in $(cat domains.txt)
do
##---laco checa tamanho do disco cada dominio feito 
dusage=$(df -Ph | grep -vE '^tmpfs|cdrom' | sed s/%//g | awk '{ if($5 > 92) print $0;}')
fscount=$(echo "$dusage" | wc -l)
if [ $fscount -ge 2 ]; then
echo "Operação cancelada para evitar que o disco lote! Kabum!"
exit
else

echo "Iniciando backup do" $domain  $(date +%F_%H:%M:%S)
/sbin/plesk bin pleskbackup --domains-name  $domain --output-file="$DESTINO"$domain".zip" -v
             echo "realizado o backup do" $domain   $(date +%F_%H:%M:%S)
    echo "Tamanho gerado:" 
     du -sh "$DESTINO"$domain".zip" | cut -f1
     fi #esse if é da condicao de disco
done

#REMOVE ARQUIVOS TEMPORARIO
echo "Iniciado a remoção de arquivos temporarios"  $(date +%F_%H:%M:%S)

 rm -rf $TEMP*

#Inserindo permissão para baixar #check e altere conforme permissão do destino
#chown "exgohs.PERMISSAO_o58l7s5eblj:psacln"

#Geral todos zip em unico arquivo
echo "Iniciando compactação .zip de todos arquivos para um unico arquivo"

zip -r /root/backupgeral.zip  $DESTINO

#Limpeza do destino
rm -rf $DESTINO*

echo "Finalizando arquivo unico"

 mv /root/backupgeral.zip $DESTINO

#Inserindo permissão para baixar #check e altere conforme permissão do destino
#chown "exgohs.PERMISSAO_o58l7s5eblj:psacln"

 chown -R admini.psaserv $DESTINO*

 echo "Job Finalizado"  $(date +%F_%H:%M:%S)
