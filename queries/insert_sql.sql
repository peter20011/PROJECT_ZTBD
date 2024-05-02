INSERT INTO olympics.person (full_name, gender, height, weight)
SELECT 'John Doe', 'Male', 180, 75
FROM information_schema.tables
LIMIT 100;

#Scenarios - Zmieniemy wartość limit i tak dostosowujemy ilośc dodanych wierszy.
# 100, 1000, 10000, 20000, 30000, 40000, 50000;