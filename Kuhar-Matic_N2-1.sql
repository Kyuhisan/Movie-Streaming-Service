use mydb;

SET @OLD_SAFE_UPDATES = @@SQL_SAFE_UPDATES;
SET SQL_SAFE_UPDATES = 0;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS Procedure_Log (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Procedure_Name VARCHAR(100),
    Start_Time DATETIME(6),
    End_Time DATETIME(6),
    Duration_Miliseconds DECIMAL(13,3),
    Num_Records INT
);

TRUNCATE TABLE Movie;
TRUNCATE TABLE Production_Studio;
TRUNCATE TABLE Procedure_Log;

DROP PROCEDURE IF EXISTS InsertProductionStudio;
DROP PROCEDURE IF EXISTS InsertMovie;
DROP PROCEDURE IF EXISTS SelectWhereMovie;
DROP PROCEDURE IF EXISTS SelectWhereAndMovie;
DROP PROCEDURE IF EXISTS SelectEveryMovie;
DROP PROCEDURE IF EXISTS UpdateWhereMovie;
DROP PROCEDURE IF EXISTS UpdateEveryMovie;
DROP PROCEDURE IF EXISTS DeleteEveryMovie;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------
-- INSERT - Neodvisna Tabela - Production Studios --
----------------------------------------------------
DELIMITER //
CREATE PROCEDURE InsertProductionStudio(IN num_records INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE start_time DATETIME(6);
    DECLARE end_time DATETIME(6);
    DECLARE duration DECIMAL(13,3);

    SET start_time = NOW(6);

    START TRANSACTION;
    WHILE i < num_records DO
        INSERT INTO Production_Studio (Studio_Name, Studio_Type, Year_Established, Budget)
        VALUES (CONCAT('Studio_', i), 
                ELT(FLOOR(1 + (RAND() * 7)), "Standalone", "Subsidiary", "Production", "Publishing", "Streaming", "Major", "Independant"), 
                FLOOR(1904 + (RAND() * (YEAR(CURDATE()) - 1904 + 1))), 
                FLOOR(1000000 + (RAND() * 100000000)));
        SET i = i + 1;
    END WHILE;
    COMMIT;

    SET end_time = NOW(6);
    SET duration = TIMESTAMPDIFF(MICROSECOND, start_time, end_time) / 1000;

	INSERT INTO Procedure_Log (Procedure_Name, Start_Time, End_Time, Duration_Miliseconds, Num_Records)
    VALUES ('INSERT --- Production Studios', start_time, end_time, duration, num_records);
END //

--------------------------------------
-- INSERT - Odvisna Tabela - Movies --
--------------------------------------
DELIMITER //
CREATE PROCEDURE InsertMovie(IN num_records INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE studio_id INT;
    DECLARE release_date DATE;
    DECLARE release_year INT;
    DECLARE start_time DATETIME(6);
    DECLARE end_time DATETIME(6);
    DECLARE duration DECIMAL(13,3);
    DECLARE min_id INT;
    DECLARE max_id INT;

    SELECT MIN(ID_Production_Studio), MAX(ID_Production_Studio) INTO min_id, max_id FROM Production_Studio;

    SET start_time = NOW(6);

    START TRANSACTION;
    WHILE i < num_records DO
        SET studio_id = FLOOR(RAND() * (max_id - min_id + 1)) + min_id;

        WHILE NOT EXISTS (SELECT 1 FROM Production_Studio WHERE ID_Production_Studio = studio_id) DO
            SET studio_id = FLOOR(RAND() * (max_id - min_id + 1)) + min_id;
        END WHILE;

        SET release_date = DATE_ADD('1950-01-01', INTERVAL RAND() * (YEAR(CURDATE()) - 1950) * 365 DAY);
        SET release_year = YEAR(release_date);

        INSERT INTO Movie (Title, Release_Year, Release_Date, Length, Movie_Description, Rating, FK_Production_Studio)
        VALUES (CONCAT('Movie_', i), 
                release_year, 
                release_date, 
                SEC_TO_TIME(FLOOR(3600 + (RAND() * 7200))),
                'Some description about the movie.', 
                NULL,
                studio_id);
        SET i = i + 1;
    END WHILE;
    COMMIT;

    SET end_time = NOW(6);
    SET duration = TIMESTAMPDIFF(MICROSECOND, start_time, end_time) / 1000;
    INSERT INTO Procedure_Log (Procedure_Name, Start_Time, End_Time, Duration_Miliseconds, Num_Records)
    VALUES ('INSERT - Movies', start_time, end_time, duration, num_records);
END //

------------------
-- SELECT-WHERE --
------------------
DELIMITER //
CREATE PROCEDURE SelectWhereMovie(IN num_records INT)
BEGIN
    DECLARE start_time DATETIME(6);
    DECLARE end_time DATETIME(6);
    DECLARE duration DECIMAL(13,3);
    
	SET start_time = NOW(6);
    START TRANSACTION;
		SELECT * FROM Movie
		WHERE release_year > 1960
        AND FK_Production_Studio > 10000;
	COMMIT;
    
	SET end_time = NOW(6);
    SET duration = TIMESTAMPDIFF(MICROSECOND, start_time, end_time) / 1000;
	INSERT INTO Procedure_Log (Procedure_Name, Start_Time, End_Time, Duration_Miliseconds, Num_Records)
    VALUES ('SELECT-WHERE --- Movies', start_time, end_time, duration, num_records);
END //

----------------------
-- SELECT-WHERE-AND --
----------------------
DELIMITER //
CREATE PROCEDURE SelectWhereAndMovie(IN num_records INT)
BEGIN
    DECLARE start_time DATETIME(6);
    DECLARE end_time DATETIME(6);
    DECLARE duration DECIMAL(13,3);
    
	SET start_time = NOW(6);
    
    START TRANSACTION;
		SELECT * FROM Movie
		WHERE YEAR(release_date) < 1960 
		AND MONTH(release_date) = MONTH(CURDATE())
        AND FK_Production_Studio > 10000;
	COMMIT;
    
	SET end_time = NOW(6);
    SET duration = TIMESTAMPDIFF(MICROSECOND, start_time, end_time) / 1000;
	INSERT INTO Procedure_Log (Procedure_Name, Start_Time, End_Time, Duration_Miliseconds, Num_Records)
    VALUES ('SELECT-WHERE-AND --- Movies', start_time, end_time, duration, num_records);
END //

------------
-- SELECT --
------------
DELIMITER //
CREATE PROCEDURE SelectEveryMovie(IN num_records INT)
BEGIN
    DECLARE start_time DATETIME(6);
    DECLARE end_time DATETIME(6);
    DECLARE duration DECIMAL(13,3);
    
	SET start_time = NOW(6);
    
    START TRANSACTION;
		SELECT * FROM Movie
	COMMIT;
    
	SET end_time = NOW(6);
    SET duration = TIMESTAMPDIFF(MICROSECOND, start_time, end_time) / 1000;
	INSERT INTO Procedure_Log (Procedure_Name, Start_Time, End_Time, Duration_Miliseconds, Num_Records)
    VALUES ('SELECT --- Movies', start_time, end_time, duration, num_records);
END //

------------------
-- UPDATE-WHERE --
------------------
DELIMITER //
CREATE PROCEDURE UpdateWhereMovie(IN num_records INT)
BEGIN
    DECLARE start_time DATETIME(6);
    DECLARE end_time DATETIME(6);
    DECLARE duration DECIMAL(13,3);
    
	SET start_time = NOW(6);
    
    START TRANSACTION;
		UPDATE Movie
		SET Movie_Description = ""
		WHERE FK_Production_Studio < 10000;
	COMMIT;
    
	SET end_time = NOW(6);
    SET duration = TIMESTAMPDIFF(MICROSECOND, start_time, end_time) / 1000;
	INSERT INTO Procedure_Log (Procedure_Name, Start_Time, End_Time, Duration_Miliseconds, Num_Records)
    VALUES ('UPDATE-WHERE --- Movies', start_time, end_time, duration, num_records);
END //

------------
-- UPDATE --
------------
DELIMITER //
CREATE PROCEDURE UpdateEveryMovie(IN num_records INT)
BEGIN
    DECLARE start_time DATETIME(6);
    DECLARE end_time DATETIME(6);
    DECLARE duration DECIMAL(13,3);
    DECLARE total_rows INT;

    SET @OLD_SAFE_UPDATES = @@SQL_SAFE_UPDATES;
    SET SQL_SAFE_UPDATES = 0;

    SET start_time = NOW(6);

    START TRANSACTION;
        SELECT COUNT(*) INTO total_rows FROM Movie;
        UPDATE Movie 
        SET FK_Production_Studio = 1111;
    COMMIT;

    SET end_time = NOW(6);
    SET duration = TIMESTAMPDIFF(MICROSECOND, start_time, end_time) / 1000;
    INSERT INTO Procedure_Log (Procedure_Name, Start_Time, End_Time, Duration_Miliseconds, Num_Records)
    VALUES ('UPDATE --- Movies', start_time, end_time, duration, total_rows);
    SET SQL_SAFE_UPDATES = @OLD_SAFE_UPDATES;
END //

------------
-- DELETE --
------------
DELIMITER //
CREATE PROCEDURE DeleteEveryMovie(IN num_records INT)
BEGIN
    DECLARE start_time DATETIME(6);
    DECLARE end_time DATETIME(6);
    DECLARE duration DECIMAL(13,3);
    
	SET start_time = NOW(6);
    
    START TRANSACTION;
		DELETE FROM Movie;        
	COMMIT;
    
	SET end_time = NOW(6);
    SET duration = TIMESTAMPDIFF(MICROSECOND, start_time, end_time) / 1000;
	INSERT INTO Procedure_Log (Procedure_Name, Start_Time, End_Time, Duration_Miliseconds, Num_Records)
    VALUES ('DELETE --- Movies', start_time, end_time, duration, num_records);
END //

INSERT INTO Procedure_Log (Procedure_Name)
VALUES ('Scenario 1.1');

CALL InsertProductionStudio(100000);
CALL InsertMovie(100000);
CALL SelectWhereMovie(100000);
CALL SelectWhereAndMovie(100000);
CALL SelectEveryMovie(100000);
CALL UpdateWhereMovie(100000);
CALL UpdateEveryMovie(100000);
CALL DeleteEveryMovie(100000);

INSERT INTO Procedure_Log (Procedure_Name)
VALUES ('Scenario 1.2');

CALL InsertProductionStudio(1000000);
CALL InsertMovie(1000000);
CALL SelectWhereMovie(1000000);
CALL SelectWhereAndMovie(1000000);
CALL SelectEveryMovie(1000000);
CALL UpdateWhereMovie(1000000);
CALL UpdateEveryMovie(1000000);
CALL DeleteEveryMovie(1000000);

SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
WHERE TABLE_NAME = 'Movie' AND REFERENCED_TABLE_NAME = 'Production_Studio';

ALTER TABLE Movie DROP FOREIGN KEY fk_movie_studio;

INSERT INTO Procedure_Log (Procedure_Name)
VALUES ('Scenario 2.1');

CALL InsertProductionStudio(100000);
CALL InsertMovie(100000);
CALL SelectWhereMovie(100000);
CALL SelectWhereAndMovie(100000);
CALL SelectEveryMovie(100000);
CALL UpdateWhereMovie(100000);
CALL UpdateEveryMovie(100000);
CALL DeleteEveryMovie(100000);

INSERT INTO Procedure_Log (Procedure_Name)
VALUES ('Scenario 2.2');

CALL InsertProductionStudio(1000000);
CALL InsertMovie(1000000);
CALL SelectWhereMovie(1000000);
CALL SelectWhereAndMovie(1000000);
CALL SelectEveryMovie(1000000);
CALL UpdateWhereMovie(1000000);
CALL UpdateEveryMovie(1000000);
CALL DeleteEveryMovie(1000000);

ALTER TABLE Movie 
ADD CONSTRAINT fk_movie_studio 
FOREIGN KEY (FK_Production_Studio) 
REFERENCES Production_Studio(ID_Production_Studio) 
ON DELETE CASCADE ON UPDATE CASCADE;

CREATE INDEX idx_release_year ON Movie (Release_Year);
INSERT INTO Procedure_Log (Procedure_Name)
VALUES ('Scenario 3.1');

CALL InsertProductionStudio(100000);
CALL InsertMovie(100000);
CALL SelectWhereMovie(100000);
CALL SelectWhereAndMovie(100000);
CALL SelectEveryMovie(100000);
CALL UpdateWhereMovie(100000);
CALL UpdateEveryMovie(100000);
CALL DeleteEveryMovie(100000);

INSERT INTO Procedure_Log (Procedure_Name)
VALUES ('Scenario 3.2');

CALL InsertProductionStudio(1000000);
CALL InsertMovie(1000000);
CALL SelectWhereMovie(1000000);
CALL SelectWhereAndMovie(1000000);
CALL SelectEveryMovie(1000000);
CALL UpdateWhereMovie(1000000);
CALL UpdateEveryMovie(1000000);
CALL DeleteEveryMovie(1000000);
DROP INDEX idx_release_year ON Movie;

CREATE INDEX idx_release_year_rating ON Movie (Release_Year, Rating);
INSERT INTO Procedure_Log (Procedure_Name)
VALUES ('Scenario 4.1');

CALL InsertProductionStudio(100000);
CALL InsertMovie(100000);
CALL SelectWhereMovie(100000);
CALL SelectWhereAndMovie(100000);
CALL SelectEveryMovie(100000);
CALL UpdateWhereMovie(100000);
CALL UpdateEveryMovie(100000);
CALL DeleteEveryMovie(100000);

INSERT INTO Procedure_Log (Procedure_Name)
VALUES ('Scenario 4.2');

CALL InsertProductionStudio(1000000);
CALL InsertMovie(1000000);
CALL SelectWhereMovie(1000000);
CALL SelectWhereAndMovie(1000000);
CALL SelectEveryMovie(1000000);
CALL UpdateWhereMovie(1000000);
CALL UpdateEveryMovie(1000000);
CALL DeleteEveryMovie(1000000);
SHOW INDEXES FROM Movie;
DROP INDEX idx_release_year_rating ON Movie;

SELECT Procedure_Name, Duration_Miliseconds FROM Procedure_Log;
SET FOREIGN_KEY_CHECKS = 1;
SET SQL_SAFE_UPDATES = @OLD_SAFE_UPDATES;

#-----------------------------------------------------------------------------------------------#
#   Kakšne razlike v času izvajanja poizvedb opažate?											#
#-----------------------------------------------------------------------------------------------#
#			    							S1 				S2	 			S3 				S4	#
# 	INSERT-STUDIO  		  100.000	  4161.260	  	  4502.618	  	  3968.795	  	  4523.082	#
# 	INSERT-STUDIO		1.000.000	 39198.822  	 38533.673		 38085.691 		 38575.382	#
#-----------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------#
#			   								S1 				S2				S3				S4	#
# 	INSERT-MOVIE   		  100.000 	  9882.668	     20308.266	     29011.507 	 	 36642.522	#
# 	INSERT-MOVIE 		1.000.000	 98929.433		163149.589		212478.403		243489.412	#
#-----------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------#
#			   							  	S1 			  	S2			  	S3			  	S4	#
# 	SELECT-WHERE  		  100.000	    91.409	       330.779	  	   132.972  	   139.731	#
# 	SELECT-WHERE 		1.000.000	  2030.079	  	  1321.579	  	  1278.276   	  1210.761	#
#-----------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------#
#			   								S1 				S2				S3				S4	#
# 	SELECT-WHERE-AND  	100.000	  		59.319	  		72.130	  		59.295	 		61.931	#
# 	SELECT-WHERE-AND 	1.000.000	  2969.741	  	  2823.882	  	  2713.276   	  2874.359	#
#-----------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------#
#			   								S1 				S2				S3				S4	#
# 	SELECT  			100.000	  	   231.603	  	   283.549	  	   262.593	  	   269.425	#
# 	SELECT 				1.000.000	  2372.736	  	  1500.306	  	  1542.665   	  1354.432	#
#-----------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------#
#			   								S1 				S2				S3				S4	#
# 	UPDATE_WHERE  		100.000	  	   214.140	  	   250.387	  		26.092	  		21.837	#
# 	UPDATE_WHERE 		1.000.000	  2248.447	  	   516.864  	  1181.423 		   156.202	#
#-----------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------#
#			   								S1 				S2				S3				S4	#
# 	UPDATE  			100.000	  	  2145.452	  	  2675.737	  	  1967.764	  	  2074.439	#
# 	UPDATE 				1.000.000	 42678.696  	 35077.308       28025.918  	 27780.389	#
#-----------------------------------------------------------------------------------------------#
#-----------------------------------------------------------------------------------------------#
#			   								S1 				S2				S3				S4	#
# 	DELETE  			100.000	  	  1516.802	  	  1383.961  	  4115.183	  	  3165.464	#
# 	DELETE 				1.000.000	101972.513	  	 94470.094	  	141330.604   	139532.775	#
#-----------------------------------------------------------------------------------------------#