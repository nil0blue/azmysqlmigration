# MySQL database migration to Azure MySQL

The pdf details a sample migration of an existing AWS MySQL RDS instance to Azure MySQL database using the Azure Database Migration Service and Online Migration.

Key Takeaways
1 Foreign keys will need to be dropped and re-added on the target database. 
2 If you're migrating over the public internet, the public IP address of the Azure database migration service will need to be discovered and added to Target database firewall and source database security group. 
3 Server parameters me need to change on the source database, requiring a reboot and maintenance window on your source database. 
4 MyISAM tables are not supported. 
5 The database migration service needs to be created in the premium tier to support online migration
6 Application downtime is minimized to the cutover period (and possibley reboot as mentioned in 3)


