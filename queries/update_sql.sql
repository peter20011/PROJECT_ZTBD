CREATE PROCEDURE update_n_height(n INT)
BEGIN
  DECLARE i INT DEFAULT 1;

  WHILE i <= n DO
    UPDATE olympics.person
    SET height = 178
    WHERE id = i;
    SET i = i + 1;
  END WHILE;
END;

#Scenarios
# 100, 1000, 10000, 20000, 30000, 40000, 50000;
CALL update_n_height(100);