-- Question 1 

SELECT 
    c.concept_name AS drug,
    COUNT(d.drug_exposure_count) AS exposure_count
FROM drug_era_1m d
INNER JOIN concept c ON c.concept_id = d.drug_concept_id
GROUP BY c.concept_name
ORDER BY exposure_count DESC
LIMIT 10;



-- Answer
-- Acetaminophen	24713
-- Hydrochlorothiazide	22791
-- levothyroxine	17572
-- Simvastatin	15861
-- Lisinopril	13764
-- Lovastatin	13033
-- Oxygen	12575
-- Propranolol	11904
-- Metformin	11722
-- Hydrocodone	10505

-- Question 2.1

WITH top_10_drugs AS (
    SELECT d.drug_concept_id,
           c.concept_name AS drug
    FROM drug_era_1m d
    INNER JOIN concept c ON c.concept_id = d.drug_concept_id
    GROUP BY d.drug_concept_id, c.concept_name
    ORDER BY COUNT(d.drug_concept_id) DESC
    LIMIT 10
)

SELECT t.drug,
       COUNT(DISTINCT d.person_id) AS num_of_people
FROM drug_era_1m d
INNER JOIN top_10_drugs t ON t.drug_concept_id = d.drug_concept_id
GROUP BY t.drug;


-- Answer
-- Acetaminophen	24439
-- Hydrochlorothiazide	22575
-- Hydrocodone	10452
-- levothyroxine	17457
-- Lisinopril	13714
-- Lovastatin	12967
-- Metformin	11640
-- Oxygen	12498
-- Propranolol	11850
-- Simvastatin	15759

-- Question 2.2

SELECT c.concept_name AS race,
	COUNT(DISTINCT(p.person_id)) AS num_of_people
FROM drug_era_1m d
INNER JOIN person p ON p.person_id = d.person_id
INNER JOIN concept c ON c.concept_id = p.race_concept_id
GROUP BY c.concept_name;

-- Answer
-- Black or African American	73355
-- No matching concept	49295
-- White	550609
-- The white race has the most number of unique patients.

-- Question 2.3

SELECT c.concept_name AS gender,
	COUNT(DISTINCT(p.person_id)) AS num_of_people
FROM drug_era_1m d
INNER JOIN person p ON p.person_id = d.person_id
INNER JOIN concept c ON c.concept_id = p.gender_concept_id
GROUP BY c.concept_name;

-- Answer
-- FEMALE	408124
-- MALE	265135
-- More women as patients compared to men.

-- Question 3.1
WITH top_10_drugs AS (
    SELECT drug_concept_id
	FROM drug_era_1m 
	GROUP BY drug_concept_id
	ORDER BY COUNT(drug_exposure_count) DESC
	LIMIT 10
),
top_10_drugs_people AS (
    SELECT DISTINCT d.person_id
    FROM drug_era_1m d 
    INNER JOIN top_10_drugs t ON t.drug_concept_id = d.drug_concept_id
),
people AS (
    SELECT d.*
    FROM drug_era_1m d
    INNER JOIN top_10_drugs_people t ON t.person_id = d.person_id
)

SELECT c.concept_name, COUNT(p.drug_exposure_count) AS exposure_count
FROM people p 
INNER JOIN concept c ON p.drug_concept_id = c.concept_id
GROUP BY c.concept_name
ORDER BY COUNT(p.drug_exposure_count) DESC
LIMIT 15;

-- Answer
-- Acetaminophen
-- Hydrochlorothiazide
-- levothyroxine
-- Simvastatin
-- Lisinopril
-- Lovastatin
-- Oxygen
-- Propranolol
-- Metformin
-- Hydrocodone
-- Dipyridamole
-- Glyburide
-- Furosemide
-- Diltiazem
-- Amitriptyline

-- Question 3.2

SELECT c.concept_name, COUNT(p.drug_exposure_count) AS exposure_count
FROM concept c 
JOIN people p ON p.drug_concept_id = c.concept_id
GROUP BY c.concept_name
ORDER BY exposure_count DESC
LIMIT 10;

-- Answer
-- Acetaminophen	24713
-- Hydrochlorothiazide	22791
-- levothyroxine	17572
-- Simvastatin	15861
-- Lisinopril	13764
-- Lovastatin	13033
-- Oxygen	12575
-- Propranolol	11904
-- Metformin	11722
-- Hydrocodone	10505

-- The two tables are the same because those who are exposed to the top 10 drugs will be included in the top 15 drug list.

-- Question 3.3

WITH drug_exposure AS (
	SELECT person_id,
	COUNT(DISTINCT drug_concept_id) AS num_drugs 
	FROM people
	GROUP BY person_id
)
SELECT AVG(num_drugs) FROM drug_exposure;

-- Answer
-- 1.7935

-- Question 3.4
WITH drug_exposure AS (
	SELECT p.person_id,
		pr.gender_concept_id,
		COUNT(DISTINCT drug_concept_id) AS num_drugs  
	FROM people p
	INNER JOIN person pr ON pr.person_id = p.person_id
	GROUP BY p.person_id, pr.gender_concept_id
)
SELECT c.concept_name,
	AVG(d.num_drugs)
FROM drug_exposure d
INNER JOIN concept c ON c.concept_id = d.gender_concept_id
GROUP BY c.concept_name;

-- Answer
-- FEMALE	1.8128
-- MALE	1.7633

-- Question 3.5
-- Answer
-- The result from the previous question suggests that females are exposed to more drug compounds than men. Hypothesis: Females are exposed to more drugs than males on average. 

-- Question 3.6
-- R Code 
-- library(tidyverse)
-- person <- read_csv("~/Downloads/person.csv")
-- concept <- read_csv("~/Downloads/concept.csv")
-- drug_era_1m <- read_csv("~/Downloads/drug_era_1m.csv")
-- concept <- concept %>% select(concept_id, concept_name)
-- person <- person %>% select(person_id, gender_concept_id)

-- top_10_drugs <- drug_era_1m %>%
--   group_by(drug_concept_id) %>%
--   summarise(exposure_count = n()) %>%
--   arrange(desc(exposure_count)) %>%
--   slice_head(n = 10)

-- top_10_drugs_people <- drug_era_1m %>%
--   filter(drug_concept_id %in% top_10_drugs$drug_concept_id) %>%
--   distinct(person_id)

-- people <- drug_era_1m %>%
--   filter(person_id %in% top_10_drugs_people$person_id) %>%
--   inner_join(person, by = "person_id")

-- people <- inner_join(people, concept, by = c("gender_concept_id" = "concept_id"))

-- df <- people %>%
--   group_by(person_id, gender_concept_id, concept_name) %>%
--   summarise(num_drugs = n_distinct(drug_concept_id), .groups = "drop")
-- df_group_male <- df %>% filter(concept_name == 'MALE') %>% select(num_drugs)
-- df_group_female <- df %>% filter(concept_name == 'FEMALE') %>% select(num_drugs)
-- t.test(df_group_male, df_group_female, var.equal = TRUE)

-- R code Output 
-- Two Sample t-test

-- data:  df_group_male and df_group_female
-- t = -9.5007, df = 144465, p-value < 2.2e-16
-- alternative hypothesis: true difference in means is not equal to 0
-- 95 percent confidence interval:
--  -0.05975116 -0.03931407
-- sample estimates:
-- mean of x mean of y 
--  1.763297  1.812830 

-- Answer
-- The 2 sample t test reveals that the mean number of drugs exposed for males and females are different. The p-value is less than 0.05. The means suggest that males are exposed to less drugs on average compared to females.