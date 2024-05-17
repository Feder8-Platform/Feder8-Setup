-- select * from lupus_relesser_final.concept where concept_id=40481925 -- No history of clinical finding in subject
-- select * from lupus_relesser_final.concept where concept_id=1340204 -- history of event
-- select * from lupus_relesser_final.concept where concept_id=442282 -- Urinary casts
-- select * from lupus_relesser_final.concept where concept_id=32883 -- survey
-- select * from lupus_relesser_final.concept where concept_id=4167328; -- Pyuria
-- select * from lupus_relesser_final.concept where concept_id=75650; -- Proteinuria
-- select * from lupus_relesser_final.concept where concept_id=79864;-- Hematuria syndrome

-- select * from lupus_relesser_final.concept where concept_id=2000004215 -- SLEDAI-2K: Urinary casts: 0 (No)
-- select * from lupus_relesser_final.concept where concept_id=2000004216 -- SLEDAI-2K: Urinary casts: 4 (Yes)
-- select * from lupus_relesser_final.concept where concept_id=2000004203 -- SLEDAI-2K: Pyuria: 0 (No)
-- select * from lupus_relesser_final.concept where concept_id=2000004204 -- SLEDAI-2K: Pyuria: 4 (Yes)
-- select * from lupus_relesser_final.concept where concept_id=2000004196 -- SLEDAI-2K: Proteinuria
-- select * from lupus_relesser_final.concept where concept_id=2000004197 -- SLEDAI-2K: Proteinuria: 0 (No)
-- select * from lupus_relesser_final.concept where concept_id=2000004198 -- SLEDAI-2K: Proteinuria: 4 (Yes)
-- select * from lupus_relesser_final.concept where concept_id=2000004167 -- SLEDAI-2K: Hematuria: 0 (No)
-- select * from lupus_relesser_final.concept where concept_id=2000004168 -- SLEDAI-2K: Hematuria: 4 (Yes)

delete from lupus_relesser_final.measurement m where m.measurement_concept_id in (2000004215, 2000004216, 2000004203, 2000004204, 2000004197, 2000004198, 2000004167, 2000004168); 

-- Add auto increment to measurement_id column
DO $$
DECLARE
    next_val INT;
BEGIN
    SELECT COALESCE(MAX(measurement_id), 0) + 1 INTO next_val FROM lupus_relesser_final.measurement;
    EXECUTE 'CREATE SEQUENCE if not exists lupus_relesser_final.measurement_id_seq START WITH ' || next_val;
END $$;
ALTER TABLE lupus_relesser_final.measurement ALTER COLUMN measurement_id SET DEFAULT nextval('lupus_relesser_final.measurement_id_seq');


-- Urinary Casts
-- Absent
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004215 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 40481925 AND value_as_concept_id = 442282 AND observation_source_concept_id IN (2000004981, 2000005284)
) AS subquery where rn = 1;
-- Present
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004216 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 1340204 AND value_as_concept_id = 442282 AND observation_source_concept_id IN (2000004982, 2000005285)
) AS subquery where rn = 1;

-- Pyuria
-- Absent
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004203 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 40481925 AND value_as_concept_id = 4167328
) AS subquery where rn = 1;
-- Present
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004204 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 1340204 AND value_as_concept_id = 4167328
) AS subquery where rn = 1;

-- Proteinuria
-- Absent
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
SELECT distinct person_id, 2000004197 AS measurement_concept_id, observation_date AS measurement_date, observation_date AS measurement_datetime, 32883 AS measurement_type_concept_id, visit_occurrence_id, visit_detail_id, observation_source_value AS measurement_source_value, observation_source_concept_id AS measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 40481925 AND value_as_concept_id = 75650 AND observation_source_concept_id IN (2000005027, 2000005415)
) AS subquery where rn = 1;
-- Present
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004198 AS measurement_concept_id, observation_date AS measurement_date, observation_date AS measurement_datetime, 32883 AS measurement_type_concept_id, visit_occurrence_id, visit_detail_id, observation_source_value AS measurement_source_value, observation_source_concept_id AS measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 1340204 AND value_as_concept_id = 75650 AND observation_source_concept_id IN (2000005028, 2000005416)
) AS subquery where rn = 1;

-- Hematuria
-- Absent
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004167 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 40481925 AND value_as_concept_id = 79864
) AS subquery where rn = 1;
-- Present
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004168 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 1340204 AND value_as_concept_id = 79864
) AS subquery where rn = 1;


select person_id, measurement_concept_id, count(*) 
from lupus_relesser_final.measurement m where m.measurement_concept_id in (2000004215, 2000004216, 2000004203, 2000004204, 2000004197, 2000004198, 2000004167, 2000004168) 
GROUP BY person_id, measurement_concept_id
having count(*) > 1;

select count(*) from lupus_relesser_final.measurement m where m.measurement_concept_id in (2000004215, 2000004216, 2000004203, 2000004204, 2000004197, 2000004198, 2000004167, 2000004168);
