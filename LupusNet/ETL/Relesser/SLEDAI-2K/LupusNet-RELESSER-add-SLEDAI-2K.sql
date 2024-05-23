delete from lupus_relesser_final.measurement m where m.measurement_concept_id in (
2000004152, 2000004153, 
2000004155, 2000004156, 
2000004158, 2000004159, 
2000004161, 2000004162,
2000004164, 2000004165,
2000004167, 2000004168, 
2000004170, 2000004171, 
2000004173, 2000004174,
2000004176, 2000004177,
2000004179, 2000004180,
2000004182, 2000004183,
2000004185, 2000004186,
2000004188, 2000004189,
2000004191, 2000004192,
2000004194, 2000004195,
2000004197, 2000004198,
2000004200, 2000004201,
2000004203, 2000004204,
2000004206, 2000004207,
2000004209, 2000004210,
2000004212, 2000004213,
2000004215, 2000004216,
2000004218, 2000004219,
2000004221, 2000004222
); 

-- Add auto increment to measurement_id column
DO $$
DECLARE
    next_val INT;
BEGIN
    SELECT COALESCE(MAX(measurement_id), 0) + 1 INTO next_val FROM lupus_relesser_final.measurement;
    EXECUTE 'CREATE SEQUENCE if not exists lupus_relesser_final.measurement_id_seq START WITH ' || next_val;
END $$;
ALTER TABLE lupus_relesser_final.measurement ALTER COLUMN measurement_id SET DEFAULT nextval('lupus_relesser_final.measurement_id_seq');


-- select * from lupus_relesser_final.concept where concept_id=40481925 -- No history of clinical finding in subject
-- select * from lupus_relesser_final.concept where concept_id=1340204 -- history of event
-- select * from lupus_relesser_final.concept where concept_id=32883 -- survey


-- Urinary Casts
-- select * from lupus_relesser_final.concept where concept_id=442282 -- Urinary casts
-- select * from lupus_relesser_final.concept where concept_id=2000004215 -- SLEDAI-2K: Urinary casts: 0 (No)
-- select * from lupus_relesser_final.concept where concept_id=2000004216 -- SLEDAI-2K: Urinary casts: 4 (Yes)
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
-- select * from lupus_relesser_final.concept where concept_id=4167328; -- Pyuria
-- select * from lupus_relesser_final.concept where concept_id=2000004203 -- SLEDAI-2K: Pyuria: 0 (No)
-- select * from lupus_relesser_final.concept where concept_id=2000004204 -- SLEDAI-2K: Pyuria: 4 (Yes)
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
-- select * from lupus_relesser_final.concept where concept_id=75650; -- Proteinuria
-- select * from lupus_relesser_final.concept where concept_id=2000004196 -- SLEDAI-2K: Proteinuria
-- select * from lupus_relesser_final.concept where concept_id=2000004197 -- SLEDAI-2K: Proteinuria: 0 (No)
-- select * from lupus_relesser_final.concept where concept_id=2000004198 -- SLEDAI-2K: Proteinuria: 4 (Yes)
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
-- select * from lupus_relesser_final.concept where concept_id=79864;-- Hematuria syndrome
-- select * from lupus_relesser_final.concept where concept_id=2000004167 -- SLEDAI-2K: Hematuria: 0 (No)
-- select * from lupus_relesser_final.concept where concept_id=2000004168 -- SLEDAI-2K: Hematuria: 4 (Yes)
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

-- Alopecia
-- select * from lupus_relesser_final.concept where concept_id=133280; -- Alopecia
-- select * from lupus_relesser_final.concept where concept_id=2000004152 -- SLEDAI-2K: Alopecia: 0 (No)
-- select * from lupus_relesser_final.concept where concept_id=2000004153 -- SLEDAI-2K: Alopecia: 2 (Yes)
-- Absent
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004152 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 40481925 AND value_as_concept_id = 133280
) AS subquery where rn = 1;
-- Present
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004153 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 1340204 AND value_as_concept_id = 133280
) AS subquery where rn = 1;


-- Arthritis
-- select * from lupus_relesser_final.concept where concept_id=4291025; -- Arthritis  
-- select * from lupus_relesser_final.concept where concept_id=2000004155 -- SLEDAI-2K: Arthritis: 0 (No)
-- select * from lupus_relesser_final.concept where concept_id=2000004156 -- SLEDAI-2K: Arthritis: 4 (Yes)
-- Absent
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004155 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 40481925 AND value_as_concept_id = 4291025
) AS subquery where rn = 1;
-- Present
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004156 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 1340204 AND value_as_concept_id = 4291025
) AS subquery where rn = 1;

-- Cerebrovascular accident
-- select * from lupus_relesser_final.concept where concept_id=381316; -- Cerebrovascular accident
-- select * from lupus_relesser_final.concept where concept_id=2000004158 -- SLEDAI-2K: Cerebrovascular accident: 0 (No)
-- select * from lupus_relesser_final.concept where concept_id=2000004159 -- SLEDAI-2K: Cerebrovascular accident: 8 (Yes)
-- Absent
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004158 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 40481925 AND value_as_concept_id = 381316
) AS subquery where rn = 1;
-- Present
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004159 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 1340204 AND value_as_concept_id = 381316
) AS subquery where rn = 1;

-- Cranial Nerve Disorder
-- select * from lupus_relesser_final.concept where concept_id=441848; -- Cranial nerve disorder
-- select * from lupus_relesser_final.concept where concept_id=2000004161 -- SLEDAI-2K: Cranial Nerve Disorder: 0 (No)
-- select * from lupus_relesser_final.concept where concept_id=2000004162 -- SLEDAI-2K: Cranial Nerve Disorder: 8 (Yes)
-- Absent
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004161 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 40481925 AND value_as_concept_id = 441848
) AS subquery where rn = 1;
-- Present
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004162 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 1340204 AND value_as_concept_id = 441848
) AS subquery where rn = 1;

-- Fever
-- select * from lupus_relesser_final.concept where concept_id=437663; -- Fever
-- select * from lupus_relesser_final.concept where concept_id=2000004164 -- SLEDAI-2K: Fever: 0 (No)
-- select * from lupus_relesser_final.concept where concept_id=2000004165 -- SLEDAI-2K: Fever: 1 (Yes)
-- Absent
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004164 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 40481925 AND value_as_concept_id = 437663
) AS subquery where rn = 1;
-- Present
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004165 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 1340204 AND value_as_concept_id = 437663
) AS subquery where rn = 1;

-- Increased DNA binding (TO BE checked!!!)
-- select * from lupus_relesser_final.concept where concept_id=2000004048; -- Increased DNA binding
-- select * from lupus_relesser_final.concept where concept_id=2000004170 -- SLEDAI-2K: High DNA binding: 0 (No)
-- select * from lupus_relesser_final.concept where concept_id=2000004171 -- SLEDAI-2K: High DNA binding: 2 (Yes)
-- Absent
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004170 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 40481925 AND value_as_concept_id = 2000004048
) AS subquery where rn = 1;
-- Present
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004171 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 1340204 AND value_as_concept_id = 2000004048
) AS subquery where rn = 1;

-- Leukopenia
-- select * from lupus_relesser_final.concept where concept_id=435224; -- Leukopenia
-- select * from lupus_relesser_final.concept where concept_id=2000004173 -- SLEDAI-2K: Leukopenia: 0 (No)
-- select * from lupus_relesser_final.concept where concept_id=2000004174 -- SLEDAI-2K: Leukopenia: 1 (Yes)
-- Absent
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004173 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 40481925 AND value_as_concept_id = 435224
) AS subquery where rn = 1;
-- Present
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004174 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 1340204 AND value_as_concept_id = 435224
) AS subquery where rn = 1;

-- Low Complement
-- select * from lupus_relesser_final.concept where concept_id=4083784; -- Complement deficiency disease
-- select * from lupus_relesser_final.concept where concept_id=2000004176 -- SLEDAI-2K: Low Complement: 0 (No)
-- select * from lupus_relesser_final.concept where concept_id=2000004177 -- SLEDAI-2K: Low Complement: 2 (Yes)
-- Absent
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004176 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 40481925 AND value_as_concept_id = 4083784
) AS subquery where rn = 1;
-- Present
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004177 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 1340204 AND value_as_concept_id = 4083784
) AS subquery where rn = 1;

-- Lupus headache
-- select * from lupus_relesser_final.concept where concept_id=378253; -- Headache
-- select * from lupus_relesser_final.concept where concept_id=2000004179 -- SLEDAI-2K: Lupus headache: 0 (No)
-- select * from lupus_relesser_final.concept where concept_id=2000004180 -- SLEDAI-2K: Lupus headache: 8 (Yes)
-- Absent
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004179 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 40481925 AND value_as_concept_id = 378253
) AS subquery where rn = 1;
-- Present
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004180 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 1340204 AND value_as_concept_id = 378253
) AS subquery where rn = 1;


-- Mucosal ulcer
-- select * from lupus_relesser_final.concept where concept_id=442121; -- Mucosal ulcer
-- select * from lupus_relesser_final.concept where concept_id=2000004182 -- SLEDAI-2K: Mucous ulcers: 0 (No)
-- select * from lupus_relesser_final.concept where concept_id=2000004183 -- SLEDAI-2K: Mucous ulcers: 2 (Yes)
-- Absent
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004182 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 40481925 AND value_as_concept_id = 442121
) AS subquery where rn = 1;
-- Present
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004183 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 1340204 AND value_as_concept_id = 442121
) AS subquery where rn = 1;

-- Myositis
-- select * from lupus_relesser_final.concept where concept_id=73001; -- Myositis
-- select * from lupus_relesser_final.concept where concept_id=2000004185 -- SLEDAI-2K: Myositis: 0 (No)
-- select * from lupus_relesser_final.concept where concept_id=2000004186 -- SLEDAI-2K: Myositis: 4 (Yes)
-- Absent
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004185 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 40481925 AND value_as_concept_id = 73001
) AS subquery where rn = 1;
-- Present
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004186 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 1340204 AND value_as_concept_id = 73001
) AS subquery where rn = 1;


-- Organic brain syndrome  
-- select * from lupus_relesser_final.concept where concept_id=373995; -- Delirium
-- select * from lupus_relesser_final.concept where concept_id=2000004188 -- SLEDAI-2K: Organic brain syndrome: 0 (No)
-- select * from lupus_relesser_final.concept where concept_id=2000004189 -- SLEDAI-2K: Organic brain syndrome: 8 (Yes)
-- Absent
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004188 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 40481925 AND value_as_concept_id = 373995
) AS subquery where rn = 1;
-- Present
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004189 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 1340204 AND value_as_concept_id = 373995
) AS subquery where rn = 1;


-- Pericarditis
-- select * from lupus_relesser_final.concept where concept_id=4138837; -- Organic brain syndrome
-- select * from lupus_relesser_final.concept where concept_id=2000004191 -- SLEDAI-2K: Pericarditis: 0 (No)
-- select * from lupus_relesser_final.concept where concept_id=2000004192 -- SLEDAI-2K: Pericarditis: 2 (Yes)
-- Absent
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004191 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 40481925 AND value_as_concept_id = 4138837
) AS subquery where rn = 1;
-- Present
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004192 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 1340204 AND value_as_concept_id = 4138837
) AS subquery where rn = 1;


-- Pleurisy
-- select * from lupus_relesser_final.concept where concept_id=78786; -- Pleurisy
-- select * from lupus_relesser_final.concept where concept_id=2000004194 -- SLEDAI-2K: Pleurisy: 0 (No)
-- select * from lupus_relesser_final.concept where concept_id=2000004195 -- SLEDAI-2K: Pleurisy: 2 (Yes)
-- Absent
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004194 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 40481925 AND value_as_concept_id = 78786
) AS subquery where rn = 1;
-- Present
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004195 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 1340204 AND value_as_concept_id = 78786
) AS subquery where rn = 1;


-- Psychosis
-- select * from lupus_relesser_final.concept where concept_id=436073; -- Psychotic disorder
-- select * from lupus_relesser_final.concept where concept_id=2000004200 -- SLEDAI-2K: Psychosis: 0 (No)
-- select * from lupus_relesser_final.concept where concept_id=2000004201 -- SLEDAI-2K: Psychosis: 8 (Yes)
-- Absent
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004200 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 40481925 AND value_as_concept_id = 436073
) AS subquery where rn = 1;
-- Present
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004201 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 1340204 AND value_as_concept_id = 436073
) AS subquery where rn = 1;


-- Rash
-- select * from lupus_relesser_final.concept where concept_id=140214; -- Eruption
-- select * from lupus_relesser_final.concept where concept_id=2000004206 -- SLEDAI-2K: Rash: 0 (No)
-- select * from lupus_relesser_final.concept where concept_id=2000004207 -- SLEDAI-2K: Rash: 2 (Yes)
-- Absent
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004206 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 40481925 AND value_as_concept_id = 140214
) AS subquery where rn = 1;
-- Present
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004207 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 1340204 AND value_as_concept_id = 140214
) AS subquery where rn = 1;


-- Seizure
-- select * from lupus_relesser_final.concept where concept_id=377091; -- Seizure
-- select * from lupus_relesser_final.concept where concept_id=2000004209 -- SLEDAI-2K: Seizure: 0 (No)
-- select * from lupus_relesser_final.concept where concept_id=2000004210 -- SLEDAI-2K: Seizure: 8 (Yes)
-- Absent
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004209 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 40481925 AND value_as_concept_id = 377091
) AS subquery where rn = 1;
-- Present
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004210 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 1340204 AND value_as_concept_id = 377091
) AS subquery where rn = 1;


-- Thrombocytopenia
-- select * from lupus_relesser_final.concept where concept_id=432870; -- Thrombocytopenic disorder
-- select * from lupus_relesser_final.concept where concept_id=2000004212 -- SLEDAI-2K: Thrombocytopenia: 0 (No)
-- select * from lupus_relesser_final.concept where concept_id=2000004213 -- SLEDAI-2K: Thrombocytopenia: 1 (Yes)
-- Absent
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004212 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 40481925 AND value_as_concept_id = 432870
) AS subquery where rn = 1;
-- Present
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004213 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 1340204 AND value_as_concept_id = 432870
) AS subquery where rn = 1;


-- Vasculitis
-- select * from lupus_relesser_final.concept where concept_id=4137275; -- Vasculitis
-- select * from lupus_relesser_final.concept where concept_id=2000004218 -- SLEDAI-2K: Vasculitis: 0 (No)
-- select * from lupus_relesser_final.concept where concept_id=2000004219 -- SLEDAI-2K: Vasculitis: 8 (Yes)
-- Absent
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004218 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 40481925 AND value_as_concept_id = 4137275
) AS subquery where rn = 1;
-- Present
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004219 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 1340204 AND value_as_concept_id = 4137275
) AS subquery where rn = 1;


-- Visual disturbance
-- select * from lupus_relesser_final.concept where concept_id=374034; -- Visual disturbance
-- select * from lupus_relesser_final.concept where concept_id=2000004221 -- SLEDAI-2K: Visual disturbance: 0 (No)
-- select * from lupus_relesser_final.concept where concept_id=2000004222 -- SLEDAI-2K: Visual disturbance: 8 (Yes)
-- Absent
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004221 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 40481925 AND value_as_concept_id = 374034
) AS subquery where rn = 1;
-- Present
insert into lupus_relesser_final.measurement (person_id, measurement_concept_id, measurement_date, measurement_datetime, measurement_type_concept_id, visit_occurrence_id, visit_detail_id, measurement_source_value, measurement_source_concept_id)
select distinct person_id, 2000004222 as measurement_concept_id, observation_date as measurement_date, observation_date as  measurement_datetime, 32883 as measurement_type_concept_id,  visit_occurrence_id, visit_detail_id, observation_source_value as measurement_source_value, observation_source_concept_id as measurement_source_concept_id
FROM (
 select person_id, observation_date, observation_date AS measurement_datetime, visit_occurrence_id, visit_detail_id, observation_source_value, observation_source_concept_id, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY observation_date) AS rn
 from lupus_relesser_final.observation o 
 where observation_concept_id = 1340204 AND value_as_concept_id = 374034
) AS subquery where rn = 1;


select person_id, measurement_concept_id, count(*) 
from lupus_relesser_final.measurement m where m.measurement_concept_id in (
2000004152, 2000004153, 
2000004155, 2000004156, 
2000004158, 2000004159, 
2000004161, 2000004162,
2000004164, 2000004165,
2000004167, 2000004168, 
2000004170, 2000004171, 
2000004173, 2000004174,
2000004176, 2000004177,
2000004179, 2000004180,
2000004182, 2000004183,
2000004185, 2000004186,
2000004188, 2000004189,
2000004191, 2000004192,
2000004194, 2000004195,
2000004197, 2000004198,
2000004200, 2000004201,
2000004203, 2000004204,
2000004206, 2000004207,
2000004209, 2000004210,
2000004212, 2000004213,
2000004215, 2000004216,
2000004218, 2000004219,
2000004221, 2000004222
)  
GROUP BY person_id, measurement_concept_id
having count(*) > 1;

select count(*) from lupus_relesser_final.measurement m where m.measurement_concept_id in (
2000004152, 2000004153, 
2000004155, 2000004156, 
2000004158, 2000004159, 
2000004161, 2000004162,
2000004164, 2000004165,
2000004167, 2000004168, 
2000004170, 2000004171, 
2000004173, 2000004174,
2000004176, 2000004177,
2000004179, 2000004180,
2000004182, 2000004183,
2000004185, 2000004186,
2000004188, 2000004189,
2000004191, 2000004192,
2000004194, 2000004195,
2000004197, 2000004198,
2000004200, 2000004201,
2000004203, 2000004204,
2000004206, 2000004207,
2000004209, 2000004210,
2000004212, 2000004213,
2000004215, 2000004216,
2000004218, 2000004219,
2000004221, 2000004222
);
