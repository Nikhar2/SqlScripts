#!/bin/bash
source ~/.bashrc
endpoint=184.105.48.49
user_name=SA
password=Nikhar@123
#endpoint=$(aws secretsmanager get-secret-value --secret-id=ion_rds_dev_secrets --region=us-east-1 | jq -r .SecretString | jq -r .rdsEndpoint)
#user_name=$(aws secretsmanager get-secret-value --secret-id=ion_rds_dev_secrets --region=us-east-1 | jq -r .SecretString | jq -r .rdsUser)
#password=$(aws secretsmanager get-secret-value --secret-id=ion_rds_dev_secrets --region=us-east-1 | jq -r .SecretString | jq -r .rdsPassword)
/opt/mssql-tools/bin/sqlcmd -S $endpoint -U $user_name -P $password -i "PurgeDB.sql"
/opt/mssql-tools/bin/sqlcmd -S $endpoint -U $user_name -P $password -Q "create database ${Environment}WarehouseManager;
        create database ${Environment}Trees;
        create database ${Environment}TreesHistory;
        create database ${Environment}International;
        create database ${Environment}InternationalHistory;
        create database ${Environment}Reporting;
        create database ${Environment}Quartz;"

$Environment = ${Environment}
echo $Environment

envsubst < Master.sql > MasterSubst.sql
/opt/mssql-tools/bin/sqlcmd -S $endpoint -U $user_name -P $password -i "MasterSubst.sql"

envsubst < MasterData.sql > MasterDataSubst.sql
/opt/mssql-tools/bin/sqlcmd -S $endpoint -U $user_name -P $password -i "MasterDataSubst.sql"

############################################################################################################################ 

envsubst < ReconciledInventoryTrees.sql > ReconciledInventoryTreesSubst.sql
/opt/mssql-tools/bin/sqlcmd -S $endpoint -U $user_name -P $password -i "ReconciledInventoryTreesSubst.sql"

############################################################################################################################

envsubst < ReconciledInventory.sql > ReconciledInventorySubst.sql
/opt/mssql-tools/bin/sqlcmd -S $endpoint -U $user_name -P $password -i "ReconciledInventorySubst.sql"

###############################################################################################################################

envsubst < ReconSkusByStoreTrees.sql > ReconSkusByStoreTreesSubst.sql
/opt/mssql-tools/bin/sqlcmd -S $endpoint -U $user_name -P $password -i "ReconSkusByStoreTreesSubst.sql"

############################################################################################################################

envsubst < ReconSkusByStore.sql > ReconSkusByStoreSubst.sql
/opt/mssql-tools/bin/sqlcmd -S $endpoint -U $user_name -P $password -i "ReconSkusByStoreSubst.sql"

############################################################################################################################

envsubst < ReconWarehouseQtyTrees.sql > ReconWarehouseQtyTreesSubst.sql
/opt/mssql-tools/bin/sqlcmd -S $endpoint -U $user_name -P $password -i "ReconWarehouseQtyTreesSubst.sql"

############################################################################################################################

envsubst < ReconWarehouseQty.sql > ReconWarehouseQtySubst.sql
/opt/mssql-tools/bin/sqlcmd -S $endpoint -U $user_name -P $password -i "ReconWarehouseQtySubst.sql"

############################################################################################################################

envsubst < Trees.sql > TreesSubst.sql
/opt/mssql-tools/bin/sqlcmd -S $endpoint -U $user_name -P $password -i "TreesSubst.sql"

envsubst < TreesData.sql > TreesDataSubst.sql
/opt/mssql-tools/bin/sqlcmd -S $endpoint -U $user_name -P $password -i "TreesDataSubst.sql"
############################################################################################################################

envsubst < TreesHistory.sql > TreesHistorySubst.sql
/opt/mssql-tools/bin/sqlcmd -S $endpoint -U $user_name -P $password -i "TreesHistorySubst.sql"

envsubst < TreesHistoryData.sql > TreesHistoryDataSubst.sql
/opt/mssql-tools/bin/sqlcmd -S $endpoint -U $user_name -P $password -i "TreesHistoryDataSubst.sql"
############################################################################################################################

envsubst < International.sql > InternationalSubst.sql
/opt/mssql-tools/bin/sqlcmd -S $endpoint -U $user_name -P $password -i "InternationalSubst.sql"

envsubst < InternationalData.sql > InternationalDataSubst.sql
/opt/mssql-tools/bin/sqlcmd -S $endpoint -U $user_name -P $password -i "InternationalDataSubst.sql"
############################################################################################################################

envsubst < InternationalHistory.sql > InternationalHistorySubst.sql
/opt/mssql-tools/bin/sqlcmd -S $endpoint -U $user_name -P $password -i "InternationalHistorySubst.sql"

envsubst < InternationalHistoryData.sql > InternationalHistoryDataSubst.sql
/opt/mssql-tools/bin/sqlcmd -S $endpoint -U $user_name -P $password -i "InternationalHistoryDataSubst.sql"
############################################################################################################################

envsubst < Reporting.sql > ReportingSubst.sql
/opt/mssql-tools/bin/sqlcmd -S $endpoint -U $user_name -P $password -i "ReportingSubst.sql"

envsubst < ReportingData.sql > ReportingDataSubst.sql
/opt/mssql-tools/bin/sqlcmd -S $endpoint -U $user_name -P $password -i "ReportingDataSubst.sql"
############################################################################################################################

envsubst < Quartz.sql > QuartzSubst.sql
/opt/mssql-tools/bin/sqlcmd -S $endpoint -U $user_name -P $password -i "QuartzSubst.sql"
