echo "Set permissions on new DB schema's"
docker exec -it postgres psql -U postgres -d OHDSI -c "REASSIGN OWNED BY feder8_admin TO ohdsi_admin;REASSIGN OWNED BY ohdsi_app_user TO ohdsi_app;GRANT USAGE ON SCHEMA lupus_almenara_final TO ohdsi_app;GRANT SELECT ON ALL TABLES IN SCHEMA lupus_almenara_final TO ohdsi_app;GRANT USAGE ON SCHEMA lupus_almenara_src TO ohdsi_app;GRANT SELECT ON ALL TABLES IN SCHEMA lupus_almenara_src TO ohdsi_app;"

echo "Query duplicate SLE diagnosis records"
docker exec -it postgres psql -U postgres -d OHDSI -c "select person_id, count(*) from lupus_almenara_final.condition_occurrence co where condition_concept_id  = 257628 group by person_id having count(*) > 1"
