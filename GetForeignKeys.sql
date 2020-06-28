select concat(fks.constraint_schema, '.', fks.table_name) as foreign_table,
       '->' as rel,
       concat(fks.unique_constraint_schema, '.', fks.referenced_table_name)
              as primary_table,
       fks.constraint_name,
       group_concat(kcu.column_name
            order by position_in_unique_constraint separator ', ') 
             as fk_columns
from information_schema.referential_constraints fks
join information_schema.key_column_usage kcu
     on fks.constraint_schema = kcu.table_schema
     and fks.table_name = kcu.table_name
     and fks.constraint_name = kcu.constraint_name
 where fks.constraint_schema = 'NBDB'
group by fks.constraint_schema,
         fks.table_name,
         fks.unique_constraint_schema,
         fks.referenced_table_name,
         fks.constraint_name
order by fks.constraint_schema,
         fks.table_name;