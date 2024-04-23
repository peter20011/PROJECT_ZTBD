CREATE PROCEDURE insert_records_custom(IN num_records INT)
BEGIN
  DECLARE i INT DEFAULT 1;

  WHILE i <= num_records DO
    INSERT INTO olympics.person (full_name, gender, height, weight) VALUES ('John Doe', 'Male', 180, 75);
    SET i = i + 1;
  END WHILE;
END;

#Scenarios
# 100, 1000, 10000, 20000, 30000, 40000, 50000;
CALL insert_records_custom(100);