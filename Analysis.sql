use projects;

select * from hospitalisation;
select * from medical_examinations;

-- 1.the average hospital charge
SELECT AVG(charges) AS average_hospital_charge
FROM hospitalisation;

-- 2.the unique customer identifiers, corresponding years, and charges from a specific dataset for records where charges exceed 700
SELECT DISTINCT customer_id, year, charges
FROM hospitalisation
WHERE charges > 700;

-- 3.the name, year, and charges for customers with a BMI greater than 35
SELECT m.customer_id, m.BMI, m.HBA1C, m.health_issues, m.any_transplant, m.cancer_history, m.numberofmajorsurgeries, m.smoker, h.year, h.charges
FROM medical_examinations m
JOIN hospitalisation h ON m.customer_id = h.customer_id
WHERE m.BMI > 35;

SELECT h.year, h.charges
FROM medical_examinations m
JOIN hospitalisation h ON m.customer_id = h.customer_id
WHERE m.BMI > 35
order by h.year desc;

-- 4. the 'customer_id' who have had major surgeries (greater than or equal to 1) 
SELECT DISTINCT customer_id , numberofmajorsurgeries
FROM medical_examinations
WHERE numberofmajorsurgeries >= 1;

-- 7.To calculate the average charges per hospital_tier for the year 2000 
SELECT hospital_tier, AVG(charges) AS average_charges
FROM hospitalisation
WHERE year = 2000
GROUP BY hospital_tier;

-- 5.To retrieve the 'customer_id,' 'BMI,' and 'charges' for customers who are smokers and have undergone a transplant
SELECT m.customer_id, m.BMI, h.charges
FROM medical_examinations m
JOIN hospitalisation h ON m.customer_id = h.customer_id
WHERE m.smoker = 'yes' AND m.any_transplant = 'Yes';

-- 6.To retrieve 'customer_id' who have had at least 2 major surgeries or a history of cancer
SELECT DISTINCT customer_id, numberofmajorsurgeries, cancer_history
FROM medical_examinations
WHERE numberofmajorsurgeries >= 2 OR cancer_history = 'Yes';

-- 8. the customer with the highest number of major surgeries
SELECT customer_id, numberofmajorsurgeries
FROM medical_examinations
WHERE numberofmajorsurgeries NOT LIKE 'No major surgery' and numberofmajorsurgeries >=3
ORDER BY CAST(numberofmajorsurgeries AS SIGNED) DESC;

-- 9.To list the customers who have had major surgeries and their respective cities' tier levels ('city_tier')
SELECT h.customer_id, h.city_tier
FROM hospitalisation h
JOIN medical_examinations m ON h.customer_id = m.customer_id
WHERE m.numberofmajorsurgeries > 0;

-- 10.To calculate the average BMI for each city_tier level in the year 1995
SELECT h.city_tier, AVG(m.BMI) AS avg_bmi
FROM hospitalisation h
JOIN medical_examinations m ON h.customer_id = m.customer_id
WHERE h.year = 1995
GROUP BY h.city_tier;

-- 11.To get the 'customer_id' and 'charges' of customers who have health issues and a BMI greater than 30 
SELECT m.customer_id, h.charges
FROM medical_examinations m
JOIN hospitalisation h ON m.customer_id = h.customer_id
WHERE m.health_issues = 'yes' AND m.BMI > 30;

-- 12.To find the customer with the highest total charges for each year and their corresponding city_tier
SELECT h.year, h.city_tier, h.customer_id, h.charges
FROM hospitalisation h
JOIN (
    SELECT year, city_tier, MAX(charges) AS max_charges
    FROM hospitalisation
    GROUP BY year, city_tier
) max_charges_subquery ON h.year = max_charges_subquery.year
                      AND h.city_tier = max_charges_subquery.city_tier
                      AND h.charges = max_charges_subquery.max_charges;
                      
WITH YearlyCharges AS (
    SELECT customer_id, AVG(charges) AS avg_yearly_charges
    FROM hospitalisation
    GROUP BY customer_id, year
)

-- 13.the top 3 customers with the highest average yearly charges
SELECT yc.customer_id, ROUND(AVG(yc.avg_yearly_charges), 2) AS avg_yearly_charges
FROM YearlyCharges yc
GROUP BY yc.customer_id
ORDER BY avg_yearly_charges DESC
LIMIT 3;

-- 14.To rank customers based on their total charges over the years in descending order
SELECT 
    customer_id, 
    SUM(charges) AS total_charges,
    RANK() OVER (ORDER BY SUM(charges) DESC) AS charges_rank
FROM 
    hospitalisation
GROUP BY 
    customer_id
ORDER BY 
    charges_rank DESC;

-- 15.the year with the highest number of hospitalizations
WITH YearlyHospitalizations AS (
    SELECT year, COUNT(*) AS hospitalization_count
    FROM hospitalisation
    GROUP BY year
)
SELECT year, hospitalization_count
FROM YearlyHospitalizations
ORDER BY hospitalization_count DESC
LIMIT 1;

-- 16.Count the Number of Customers with Health Issues
SELECT COUNT(*) AS health_issues_count
FROM medical_examinations
WHERE health_issues = 'yes';

-- 17.Average BMI for Smokers
SELECT AVG(BMI) AS avg_bmi_for_smokers
FROM medical_examinations
WHERE smoker = 'yes';

-- 18. List Customers with Frequent Treatment
SELECT Count(*) as Frequent_Customers
FROM hospitalisation
WHERE Is_Frequent_Treatment = 'Yes';

-- 19.Retrieve Customer Information with Cancer History
SELECT customer_id,BMI,HBA1C,health_issues,smoker
FROM medical_examinations
WHERE cancer_history = 'Yes';

-- 20.Calculate the Total Charges per City Tier
SELECT city_tier, SUM(charges) AS total_charges
FROM hospitalisation
GROUP BY city_tier;

-- 21.Identify Customers with Children and Frequent Treatment
SELECT *
FROM hospitalisation
WHERE Has_Children = 'Yes' AND Is_Frequent_Treatment = 'Yes';

-- 22.Find the Average HBA1C Level for Customers with Health Issues
SELECT AVG(HBA1C) AS avg_hba1c_for_health_issues
FROM medical_examinations
WHERE health_issues = 'yes';

-- 23.Identify Customers with Health Issues and High Charges
WITH HealthIssuesAndHighCharges AS (
    SELECT h.customer_id, h.charges
    FROM hospitalisation h
    JOIN medical_examinations m ON h.customer_id = m.customer_id
    WHERE m.health_issues = 'yes' AND h.charges > (SELECT AVG(charges) FROM hospitalisation)
)
SELECT *
FROM HealthIssuesAndHighCharges;

-- 24.Calculate the Average Charges per Year and City Tier
SELECT year, city_tier, AVG(charges) AS avg_charges
FROM hospitalisation
GROUP BY year, city_tier;

-- 25.Find Customers with High Charges and Frequent Treatment
SELECT *
FROM hospitalisation
WHERE charges > (SELECT AVG(charges) FROM hospitalisation)
  AND Is_Frequent_Treatment = 'Yes';
  
-- 26.List Customers with Transplants and High BMI
SELECT *
FROM medical_examinations
WHERE any_transplant = 'Yes' AND BMI > (SELECT AVG(BMI) FROM medical_examinations);

-- 27.Calculate the Cumulative Charges Over Time
SELECT customer_id, year, SUM(charges) OVER (PARTITION BY customer_id ORDER BY year) AS cumulative_charges
FROM hospitalisation;

-- 28.Identify Customers with Consistent Frequent Treatment
SELECT customer_id
FROM hospitalisation
WHERE Is_Frequent_Treatment = 'Yes'
GROUP BY customer_id
HAVING COUNT(DISTINCT year) = (SELECT COUNT(DISTINCT year) FROM hospitalisation);

-- 29.Find Customers with Fluctuating BMI
SELECT customer_id
FROM medical_examinations
GROUP BY customer_id
HAVING MAX(BMI) - MIN(BMI) > 5;

-- 29. Calculate the Percentage of Customers with Children
SELECT Has_Children, COUNT(*) * 100.0 / (SELECT COUNT(*) FROM hospitalisation) AS percentage
FROM hospitalisation
GROUP BY Has_Children;

-- 30. Identify Customers with a History of Cancer and High Charges
SELECT *
FROM medical_examinations m
JOIN hospitalisation h ON m.customer_id = h.customer_id
WHERE m.cancer_history = 'Yes' AND h.charges > (SELECT AVG(charges) FROM hospitalisation);