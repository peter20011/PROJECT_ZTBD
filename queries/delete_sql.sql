CREATE PROCEDURE delete_n_records(n INT)
BEGIN
  DECLARE i INT DEFAULT 1;

  WHILE i <= n DO
    DELETE FROM olympics.person WHERE id = i;
    SET i = i + 1;
  END WHILE;
END;

#Scenarios
# 100, 1000, 10000, 20000, 30000, 40000, 50000;
CALL delete_n_records(100);