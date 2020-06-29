# AWS RDS MySQL database migration to Azure MySQL

The pdf details a sample migration of an existing AWS MySQL RDS instance to Azure MySQL database using the Azure Database Migration Service and Online Migration.

Key Takeaways


1 Foreign keys and Triggers will need to be dropped/disabled and re-added on the target database. 

2 If you're migrating over the public internet, you'll need to create a static public IP and associate it with the NIC generated when the DMS is deployed. Then allow access from this public IP to your source and target database security group/firewall rules.  

3 Server parameters may need to be modified on the source database, requiring a reboot and maintenance window on your source database. 

4 MyISAM tables are not supported. 

5 The database migration service needs to be created in the premium tier to support online migration

6 Application downtime is minimized to the cutover period (and possibley reboot as mentioned in 3)

The template below is a quickstart to deploy the Azure DMS service with source and target types configured as MySQL. It will also create a Target MySQL database in Azure. Loading the DB Schema and starting the Migration Activity has not been automated yet.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fnil0blue%2Fazmysqlmigration%2Fmaster%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fnil0blue%2Fazmysqlmigration%2Fmaster%2Fazuredeploy.json)
