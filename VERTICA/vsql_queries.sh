#!/bin/bash

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#
# Queries to get 360 degree view of Vertica database cluster - vsql_queries.sh
#
# Usage:
# 1) Download the script or copy the contents
# of the script and save it as vsql_queries.sh
# 2) Make it executable: chmod +x vsql_queries.sh
# reads from standard input or command line
# 3) Run the script: time ./vsql_queries.sh username password > log.out 2> log_error.out
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#

if [ $# -ne 2 ]; then
	
	echo "==> Usage: time ./vsql_queries.sh username password > log.out 2> log_error.out"
	exit -1
	
fi

vertica_bin_dir="/opt/vertica/bin/"
username="$1"
password="$2"

vsql_call ()
{
"$vertica_bin_dir"vsql -U "$username" -w "$password" -c "$1" "$2"
}

command="SELECT * FROM licenses;"
printf "\n==> QUERY 1. Checking Vertica License:\n\n" && vsql_call "$command"

command="SELECT VERSION();"
printf "\n==> QUERY 2. Checking Vertica Version:\n\n" && vsql_call "$command"

command="\l"
printf "\n==> QUERY 3. Listing Vertica Database:\n\n" && vsql_call "$command"

command="\dt"
printf "\n==> QUERY 4. Listing all the tables in Vertica Database:\n\n" && vsql_call "$command"

command="\dj"
printf "\n==> QUERY 5. Listing all the projections in Vertica Database:\n\n" && vsql_call "$command"

command="\dp"
printf "\n==> QUERY 6. Listing privileges:\n\n" && vsql_call "$command"

command="SELECT GET_COMPLIANCE_STATUS();"
printf "\n==> QUERY 7. Displaying license details before fresh audit:\n\n" && vsql_call "$command"

command="SELECT AUDIT_LICENSE_SIZE();"
printf "\n==> QUERY 8. Displaying license details after fresh audit running in background:\n\n" && vsql_call "$command"

command="SELECT AUDIT('');"
printf "\n==> QUERY 9. Displaying license details after fresh synchronous audit:\n\n" && vsql_call "$command"

command="SELECT * FROM NODES;"
printf "\n==> QUERY 10. Displaying information about the cluster nodes:\n\n" && vsql_call "$command"

command="SELECT table_schema, table_name, owner_name, is_temp_table, is_system_table, is_flextable, system_table_creator, partition_expression, create_time, table_definition FROM v_catalog.tables;"
printf "\n==> QUERY 11. tables info.\n\n" && vsql_call "$command" -x

command="SELECT TIMESTAMP 'NOW' AS TIMESTAMP;"
printf "\n==> QUERY 12. timestamp\n\n" && vsql_call "$command"

command="SELECT CLOCK_TIMESTAMP() \"Current Time\";"
printf "\n==> QUERY 13. current time\n\n" && vsql_call "$command"

command="SELECT SESSION_USER();"
printf "\n==> QUERY 14. session user\n\n" && vsql_call "$command"

command="SELECT * from user_audits;"
printf "\n==> QUERY 15. user audits\n\n" && vsql_call "$command" -x

command="SELECT AUDIT_LICENSE_TERM();"
printf "\n==> QUERY 16. License Info.\n\n" && vsql_call "$command"

command="SELECT * FROM sessions;"
printf "\n==> QUERY 17. sessions info\n\n" && vsql_call "$command" -x

command="SELECT CURRENT_VALUE FROM CONFIGURATION_PARAMETERS WHERE parameter_name='MaxClientSessions';"
printf "\n==> QUERY 18. MaxClientSessions\n\n" && vsql_call "$command"

command="SELECT * FROM v_monitor.data_collector;"
printf "\n==> QUERY 19. DATA_COLLECTOR\n\n" && vsql_call "$command" -x

command="SELECT DISPLAY_LICENSE();"
printf "\n==> QUERY 20. LICENSE INFO.\n\n" && vsql_call "$command"

command="SELECT DUMP_CATALOG();"
printf "\n==> QUERY 21. CATALOG DUMP\n\n" && vsql_call "$command" -x

command="SELECT DUMP_PARTITION_KEYS( );"
printf "\n==> QUERY 22. PARTITION KEYS DUMP\n\n" && vsql_call "$command" -x

command="SELECT get_data_collector_policy('ResourceAcquisitions');"
printf "\n==> QUERY 23. DATA COLLECTION POLICY\n\n" && vsql_call "$command"

command="SELECT name, assigned_roles FROM roles;"
printf "\n==> QUERY 24. ROLES\n\n" && vsql_call "$command"

command="SELECT node_name from DISK_STORAGE;"
printf "\n==> QUERY 25. DISK STORAGE\n\n" && vsql_call "$command"

command="SELECT * FROM V_MONITOR.SESSIONS;"
printf "\n==> QUERY 26. SESSIONS INFO.\n\n" && vsql_call "$command" -x

command="SELECT * from SYSTEM;"
printf "\n==> QUERY 27. SYSTEM INFO.\n\n" && vsql_call "$command"

command="SELECT * FROM CONFIGURATION_PARAMETERS;"
printf "\n==> QUERY 28. CONFIGURATION PARAMETERS\n\n" && vsql_call "$command" -x

command="SELECT * from user_functions;"
printf "\n==> QUERY 29. USER FUNCTIONS\n\n" && vsql_call "$command" -x

command="SELECT DISTINCT table_name, table_type FROM all_tables WHERE table_type ILIKE 'TABLE';"
printf "\n==> QUERY 30. TABLES INFO.\n\n" && vsql_call "$command"

command="SELECT cluster_position FROM cluster_layout;"
printf "\n==> QUERY 31. CLUSTER LAYOUT\n\n" && vsql_call "$command"

command="SELECT * FROM elastic_cluster;"
printf "\n==> QUERY 32. CLUSTER INFP.\n\n" && vsql_call "$command" -x

command="SELECT * FROM epochs;"
printf "\n==> QUERY 33. EPOCHS\n\n" && vsql_call "$command"

command="SELECT member_type, member_name, parent_type, CASE WHEN parent_type = 'DATABASE' THEN '' ELSE parent_name END FROM fault_groups ORDER BY member_name;"
printf "\n==> QUERY 34. FAULT GROUPS\n\n" && vsql_call "$command"

command="SELECT segment_layout from elastic_cluster;"
printf "\n==> QUERY 35. CLUSTER LAYOUT\n\n" && vsql_call "$command"

command="SELECT constraint_name, table_name, ordinal_position, reference_table_name FROM foreign_keys ORDER BY 3;"
printf "\n==> QUERY 36. FOREIGN KEYS\n\n" && vsql_call "$command"

command="SELECT grantor, privileges_description, object_schema, object_name, grantee FROM grants;"
printf "\n==> QUERY 37. PERMISSIONS\n\n" && vsql_call "$command"

command="SELECT table_name, creation_time, key_name, status, message FROM v_catalog.materialize_flextable_columns_results;"
printf "\n==> QUERY 38. FLEXTABLE INFO.\n\n" && vsql_call "$command"

command="SELECT constraint_name, table_name, ordinal_position, table_schema FROM primary_keys ORDER BY 3;"
printf "\n==> QUERY 39. PRIMARY KEYS\n\n" && vsql_call "$command"

command="SELECT * FROM V_CATALOG.RESOURCE_POOLS;"
printf "\n==> QUERY 40. RESOURCE POOLS\n\n" && vsql_call "$command" -x

command="SELECT * FROM users;"
printf "\n==> QUERY 41. USERS\n\n" && vsql_call "$command" -x

command="SELECT * FROM roles;"
printf "\n==> QUERY 42. ROLES\n\n" && vsql_call "$command"

command="SELECT * FROM schemata;"
printf "\n==> QUERY 43. SCHEMATA\n\n" && vsql_call "$command"

command="SELECT * FROM sequences;"
printf "\n==> QUERY 44. SEQUENCES\n\n" && vsql_call "$command"

command="SELECT * FROM storage_locations;"
printf "\n==> QUERY 45. storage locations\n\n" && vsql_call "$command"

command="SELECT * FROM user_procedures;"
printf "\n==> QUERY 46. user procedures\n\n" && vsql_call "$command"

command="SELECT table_schema, table_name, column_name, column_id, data_type FROM system_columns;"
printf "\n==> QUERY 47. INFO.\n\n" && vsql_call "$command"

command="SELECT * FROM CONFIGURATION_PARAMETERS WHERE parameter_name = 'JavaBinaryForUDx';"
printf "\n==> QUERY 48. JavaBinaryForUDx\n\n" && vsql_call "$command"

command="SELECT table_schema, table_name, create_time FROM tables;"
printf "\n==> QUERY 49. TABLES INFO.\n\n" && vsql_call "$command"

command="SELECT * FROM VIEWS;"
printf "\n==> QUERY 50. VIEWS\n\n" && vsql_call "$command"

command="SELECT * FROM active_events;"
printf "\n==> QUERY 51. ACTIVE EVENTS\n\n" && vsql_call "$command" -x

command="SELECT * FROM column_storage;"
printf "\n==> QUERY 52. COLUMN STORAGE\n\n" && vsql_call "$command" -x

command="SELECT * FROM configuration_changes;"
printf "\n==> QUERY 53. CONFIGURATION CHANGES\n\n" && vsql_call "$command"

command="SELECT * FROM cpu_usage ORDER BY average_cpu_usage_percent DESC LIMIT 10;"
printf "\n==> QUERY 54. CPU USAGE\n\n" && vsql_call "$command"

command="SELECT * FROM cpu_usage ORDER BY average_cpu_usage_percent ASC LIMIT 10;"
printf "\n==> QUERY 55. CPU USAGE II\n\n" && vsql_call "$command"

command="SELECT * FROM critical_hosts;"
printf "\n==> QUERY 56. critical hosts\n\n" && vsql_call "$command"

command="SELECT * FROM v_monitor.critical_nodes;"
printf "\n==> QUERY 57. critical nodes\n\n" && vsql_call "$command"

command="SELECT * from v_monitor.database_backups;"
printf "\n==> QUERY 58. database backups\n\n" && vsql_call "$command"

command="SELECT * FROM DATABASE_CONNECTIONS;"
printf "\n==> QUERY 59. database connections\n\n" && vsql_call "$command"

command="SELECT * FROM database_snapshots;"
printf "\n==> QUERY 60. database snapshots\n\n" && vsql_call "$command"

command="SELECT * from v_monitor.deploy_status;"
printf "\n==> QUERY 61. deploy status\n\n" && vsql_call "$command"

command="SELECT * FROM DEPLOYMENT_PROJECTIONS;"
printf "\n==> QUERY 62. DEPLOYMENT PROJECTIONS\n\n" && vsql_call "$command"

command="SELECT event_time, design_name, design_phase, phase_complete_percent FROM v_monitor.design_status;"
printf "\n==> QUERY 63. Design Status\n\n" && vsql_call "$command"

command="SELECT * FROM DESIGN_TABLES;"
printf "\n==> QUERY 64. Design Tables\n\n" && vsql_call "$command"

command="SELECT * FROM DESIGNS;"
printf "\n==> QUERY 65. Designs\n\n" && vsql_call "$command"

command="SELECT * FROM disk_resource_rejections;"
printf "\n==> QUERY 66. disk resource rejections\n\n" && vsql_call "$command"

command="SELECT * FROM DISK_STORAGE;"
printf "\n==> QUERY 67. DISK STORAGE\n\n" && vsql_call "$command" -x

command="SELECT event_timestamp, statement_id, error_level, message FROM error_messages WHERE error_level='ERROR';"
printf "\n==> QUERY 68. error messages\n\n" && vsql_call "$command" -x

command="SELECT * FROM HOST_RESOURCES;"
printf "\n==> QUERY 69. HOST RESOURCES\n\n" && vsql_call "$command" -x

command="SELECT * FROM io_usage ORDER BY written_kbytes_per_sec DESC LIMIT 10;"
printf "\n==> QUERY 70. IO USAGE I\n\n" && vsql_call "$command"

command="SELECT * FROM io_usage ORDER BY written_kbytes_per_sec ASC LIMIT 10;"
printf "\n==> QUERY 71. IO USAGE II\n\n" && vsql_call "$command"

command="SELECT * FROM io_usage ORDER BY read_kbytes_per_sec ASC LIMIT 10;"
printf "\n==> QUERY 72. IO USAGE III\n\n" && vsql_call "$command"

command="SELECT * FROM io_usage ORDER BY read_kbytes_per_sec DESC LIMIT 10;"
printf "\n==> QUERY 73. IO USAGE IV\n\n" && vsql_call "$command"

command="SELECT * FROM memory_usage ORDER BY average_memory_usage_percent DESC LIMIT 10;"
printf "\n==> QUERY 74. MEMORY USAGE I\n\n" && vsql_call "$command"

command="SELECT * FROM memory_usage ORDER BY average_memory_usage_percent ASC LIMIT 10;"
printf "\n==> QUERY 75. MEMORY USAGE II\n\n" && vsql_call "$command"

command="SELECT * FROM network_interfaces;"
printf "\n==> QUERY 76. NETWORK INTERFACES\n\n" && vsql_call "$command"

command="SELECT node_name, start_time, end_time, tx_kbytes_per_sec AS tx_kb, rx_kbytes_per_sec AS rx_kb FROM network_usage ORDER BY rx_kb DESC LIMIT 10;"
printf "\n==> QUERY 77. NETWORK USAGE I\n\n" && vsql_call "$command"

command="SELECT node_name, start_time, end_time, tx_kbytes_per_sec AS tx_kb, rx_kbytes_per_sec AS rx_kb FROM network_usage ORDER BY tx_kb DESC LIMIT 10;"
printf "\n==> QUERY 78. NETWORK USAGE II\n\n" && vsql_call "$command"

command="SELECT node_name, start_time, end_time, tx_kbytes_per_sec AS tx_kb, rx_kbytes_per_sec AS rx_kb FROM network_usage ORDER BY rx_kb ASC LIMIT 10;"
printf "\n==> QUERY 79. NETWORK USAGE III\n\n" && vsql_call "$command"

command="SELECT node_name, start_time, end_time, tx_kbytes_per_sec AS tx_kb, rx_kbytes_per_sec AS rx_kb FROM network_usage ORDER BY tx_kb ASC LIMIT 10;"
printf "\n==> QUERY 80. NETWORK USAGE IV\n\n" && vsql_call "$command"

command="SELECT * FROM NODE_RESOURCES;"
printf "\n==> QUERY 81. node resources\n\n" && vsql_call "$command"

command="SELECT * FROM node_states;"
printf "\n==> QUERY 82. node states\n\n" && vsql_call "$command"

command="SELECT * FROM partition_status;"
printf "\n==> QUERY 83. Partitions Info. I\n\n" && vsql_call "$command"

command="SELECT PARTITION_KEY, PROJECTION_NAME, ROS_ID, ROS_SIZE_BYTES, ROS_ROW_COUNT, NODE_NAME FROM partitions;"
printf "\n==> QUERY 84. Partitions Info. II\n\n" && vsql_call "$command"

command="SELECT * FROM projection_storage;"
printf "\n==> QUERY 85. Projection Storage\n\n" && vsql_call "$command"

command="SELECT query_start_timestamp, node_name, user_name, request_id, io_type, projection_id, projection_name, anchor_table_name FROM projection_usage LIMIT 10;"
printf "\n==> QUERY 86. Projection Usage\n\n" && vsql_call "$command"

command="SELECT * FROM QUERY_PROFILES ORDER BY query_duration_us DESC LIMIT 10;"
printf "\n==> QUERY 87. QUERY PROFILES\n\n" && vsql_call "$command" -x

command="SELECT * FROM RESOURCE_USAGE;"
printf "\n==> QUERY 88. RESOURCE USAGE\n\n" && vsql_call "$command" -x

command="SELECT * from udx_fenced_processes;"
printf "\n==> QUERY 89. user-defined extensions\n\n" && vsql_call "$command"

command="select DESIGNED_FAULT_TOLERANCE, CURRENT_FAULT_TOLERANCE from system;"
printf "\n==> QUERY 90. Check K-Safety\n\n" && vsql_call "$command"