use mydb;
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE Movie;
TRUNCATE TABLE Production_Studio;
TRUNCATE TABLE Procedure_Log;
SET FOREIGN_KEY_CHECKS = 1;

DROP PROCEDURE IF EXISTS InsertProductionStudios;
DROP PROCEDURE IF EXISTS InsertMovies;
DROP PROCEDURE IF EXISTS SelectWhereMovie;
DROP PROCEDURE IF EXISTS SelectWhereAndMovie;
DROP PROCEDURE IF EXISTS SelectEveryMovie;
DROP PROCEDURE IF EXISTS UpdateWhereMovie;
DROP PROCEDURE IF EXISTS UpdateEveryMovie;
DROP PROCEDURE IF EXISTS DeleteEveryMovie;
DROP TABLE Procedure_Log;

CREATE TABLE IF NOT EXISTS Procedure_Log (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Procedure_Name VARCHAR(100),
    Start_Time DATETIME,
    End_Time DATETIME,
    Duration_Seconds DECIMAL(10,3),
    Num_Records INT
);

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------
-- INSERT - Neodvisna Tabela - Production Studios --
----------------------------------------------------

DELIMITER //
CREATE PROCEDURE InsertProductionStudios(IN num_records INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE start_time DATETIME;
    DECLARE end_time DATETIME;
    DECLARE duration DECIMAL(10,3);

    SET start_time = NOW();

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

    SET end_time = NOW();
    SET duration = TIMESTAMPDIFF(MICROSECOND, start_time, end_time) / 1000000;

	INSERT INTO Procedure_Log (Procedure_Name, Start_Time, End_Time, Duration_Seconds, Num_Records)
    VALUES ('INSERT --- Production Studios', start_time, end_time, duration, num_records);
END //

--------------------------------------
-- INSERT - Odvisna Tabela - Movies --
--------------------------------------
DELIMITER //
CREATE PROCEDURE InsertMovies(IN num_records INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE studio_id INT;
    DECLARE release_date DATE;
    DECLARE release_year INT;
    DECLARE start_time DATETIME;
    DECLARE end_time DATETIME;
    DECLARE duration DECIMAL(10,3);
    DECLARE min_id INT;
    DECLARE max_id INT;

    SELECT MIN(ID_Production_Studio), MAX(ID_Production_Studio) INTO min_id, max_id FROM Production_Studio;

    SET start_time = NOW();

    START TRANSACTION;
    WHILE i < num_records DO
        SET studio_id = FLOOR(RAND() * (max_id - min_id + 1)) + min_id;

        WHILE NOT EXISTS (SELECT 1 FROM Production_Studio WHERE ID_Production_Studio = studio_id) DO
            SET studio_id = FLOOR(RAND() * (max_id - min_id + 1)) + min_id;
        END WHILE;

        SET release_date = DATE_ADD('1950-01-01', INTERVAL RAND() * (YEAR(CURDATE()) - 1950) * 365 DAY);
        SET release_year = YEAR(release_date);

        INSERT INTO Movie (Title, Release_Year, Release_Date, Length, Movie_Description, Rating, Production_Studio_ID_Production_Studio)
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

    SET end_time = NOW();
    SET duration = TIMESTAMPDIFF(MICROSECOND, start_time, end_time) / 1000000;

    INSERT INTO Procedure_Log (Procedure_Name, Start_Time, End_Time, Duration_Seconds, Num_Records)
    VALUES ('INSERT - Movies', start_time, end_time, duration, num_records);
END //

------------------
-- SELECT-WHERE --
------------------
DELIMITER //
CREATE PROCEDURE SelectWhereMovie(IN num_records INT)
BEGIN
    DECLARE start_time DATETIME;
    DECLARE end_time DATETIME;
    DECLARE duration DECIMAL(10,3);
    
	SET start_time = NOW();
    START TRANSACTION;
		SELECT * FROM Movie
		WHERE release_year < 1960;
	COMMIT;
    
	SET end_time = NOW();
    SET duration = TIMESTAMPDIFF(MICROSECOND, start_time, end_time) / 1000000;

	INSERT INTO Procedure_Log (Procedure_Name, Start_Time, End_Time, Duration_Seconds, Num_Records)
    VALUES ('SELECT-WHERE --- Movies', start_time, end_time, duration, num_records);
END //

----------------------
-- SELECT-WHERE-AND --
----------------------
DELIMITER //
CREATE PROCEDURE SelectWhereAndMovie(IN num_records INT)
BEGIN
    DECLARE start_time DATETIME;
    DECLARE end_time DATETIME;
    DECLARE duration DECIMAL(10,3);
    
	SET start_time = NOW();
    
    START TRANSACTION;
		SELECT * FROM Movie
		WHERE YEAR(release_date) < 1960 
		AND MONTH(release_date) = MONTH(CURDATE());
	COMMIT;
    
	SET end_time = NOW();
    SET duration = TIMESTAMPDIFF(MICROSECOND, start_time, end_time) / 1000000;

	INSERT INTO Procedure_Log (Procedure_Name, Start_Time, End_Time, Duration_Seconds, Num_Records)
    VALUES ('SELECT-WHERE-AND --- Movies', start_time, end_time, duration, num_records);
END //

------------
-- SELECT --
------------
DELIMITER //
CREATE PROCEDURE SelectEveryMovie(IN num_records INT)
BEGIN
    DECLARE start_time DATETIME;
    DECLARE end_time DATETIME;
    DECLARE duration DECIMAL(10,3);
    
	SET start_time = NOW();
    
    START TRANSACTION;
		SELECT * FROM Movie
	COMMIT;
    
	SET end_time = NOW();
    SET duration = TIMESTAMPDIFF(MICROSECOND, start_time, end_time) / 1000000;

	INSERT INTO Procedure_Log (Procedure_Name, Start_Time, End_Time, Duration_Seconds, Num_Records)
    VALUES ('SELECT --- Movies', start_time, end_time, duration, num_records);
END //

------------------
-- UPDATE-WHERE --
------------------
DELIMITER //
CREATE PROCEDURE UpdateWhereMovie(IN num_records INT)
BEGIN
    DECLARE start_time DATETIME;
    DECLARE end_time DATETIME;
    DECLARE duration DECIMAL(10,3);
    
	SET start_time = NOW();
    
    START TRANSACTION;
		SELECT * FROM Movie
	COMMIT;
    
	SET end_time = NOW();
    SET duration = TIMESTAMPDIFF(MICROSECOND, start_time, end_time) / 1000000;

	INSERT INTO Procedure_Log (Procedure_Name, Start_Time, End_Time, Duration_Seconds, Num_Records)
    VALUES ('UPDATE-WHERE --- Movies', start_time, end_time, duration, num_records);
END //

------------
-- UPDATE --
------------
DELIMITER //
CREATE PROCEDURE UpdateEveryMovie(IN num_records INT)
BEGIN
    DECLARE start_time DATETIME;
    DECLARE end_time DATETIME;
    DECLARE duration DECIMAL(10,3);
    DECLARE total_rows INT;

    SET @OLD_SAFE_UPDATES = @@SQL_SAFE_UPDATES;
    SET SQL_SAFE_UPDATES = 0;

    SET start_time = NOW();

    START TRANSACTION;
        SELECT COUNT(*) INTO total_rows FROM Movie;
        UPDATE Movie 
        SET Movie_Description = '';
    COMMIT;

    SET end_time = NOW();
    SET duration = TIMESTAMPDIFF(MICROSECOND, start_time, end_time) / 1000000;

    INSERT INTO Procedure_Log (Procedure_Name, Start_Time, End_Time, Duration_Seconds, Num_Records)
    VALUES ('UPDATE --- Movies', start_time, end_time, duration, total_rows);
    SET SQL_SAFE_UPDATES = @OLD_SAFE_UPDATES;
END //

------------
-- DELETE --
------------
DELIMITER //
CREATE PROCEDURE DeleteEveryMovie(IN num_records INT)
BEGIN
    DECLARE start_time DATETIME;
    DECLARE end_time DATETIME;
    DECLARE duration DECIMAL(10,3);
    
	SET start_time = NOW();
    
    START TRANSACTION;
		DELETE FROM Movie;        
	COMMIT;
    
	SET end_time = NOW();
    SET duration = TIMESTAMPDIFF(MICROSECOND, start_time, end_time) / 1000000;

	INSERT INTO Procedure_Log (Procedure_Name, Start_Time, End_Time, Duration_Seconds, Num_Records)
    VALUES ('DELETE --- Movies', start_time, end_time, duration, num_records);
END //

INSERT INTO Procedure_Log (Procedure_Name)
VALUES ('Scenario 1.1');

CALL InsertProductionStudios(100000);
CALL InsertMovies(100000);
CALL SelectWhereMovies(100000);
CALL SelectWhereAndMovie(100000);
CALL SelectEveryMovie(100000);
CALL UpdateWhereMovie(100000);
CALL UpdateEveryMovie(100000);
CALL DeleteEveryMovie(100000);

INSERT INTO Procedure_Log (Procedure_Name)
VALUES ('Scenario 1.2');

CALL InsertProductionStudios(1000000);
CALL InsertMovies(1000000);
CALL SelectWhereMovies(1000000);
CALL SelectWhereAndMovie(1000000);
CALL SelectEveryMovie(1000000);
CALL UpdateWhereMovie(1000000);
CALL UpdateEveryMovie(1000000);
CALL DeleteEveryMovie(1000000);

SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
WHERE TABLE_NAME = 'Movie' AND REFERENCED_TABLE_NAME = 'Production_Studio';

ALTER TABLE Movie DROP FOREIGN KEY fk_Movie_Studio;

INSERT INTO Procedure_Log (Procedure_Name)
VALUES ('Scenario 2.1');

CALL InsertProductionStudios(100000);
CALL InsertMovies(100000);
CALL SelectWhereMovies(100000);
CALL SelectWhereAndMovie(100000);
CALL SelectEveryMovie(100000);
CALL UpdateWhereMovie(100000);
CALL UpdateEveryMovie(100000);
CALL DeleteEveryMovie(100000);

INSERT INTO Procedure_Log (Procedure_Name)
VALUES ('Scenario 2.2');

CALL InsertProductionStudios(1000000);
CALL InsertMovies(1000000);
CALL SelectWhereMovies(1000000);
CALL SelectWhereAndMovie(1000000);
CALL SelectEveryMovie(1000000);
CALL UpdateWhereMovie(1000000);
CALL UpdateEveryMovie(1000000);
CALL DeleteEveryMovie(1000000);

ALTER TABLE Movie 
ADD CONSTRAINT fk_movie_studio 
FOREIGN KEY (Production_Studio_ID_Production_Studio) 
REFERENCES Production_Studio(ID_Production_Studio) 
ON DELETE CASCADE ON UPDATE CASCADE;

DROP INDEX idx_release_year ON Movie;
CREATE INDEX idx_release_year ON Movie (Release_Year);

INSERT INTO Procedure_Log (Procedure_Name)
VALUES ('Scenario 3.1');

CALL InsertProductionStudios(100000);
CALL InsertMovies(100000);
CALL SelectWhereMovies(100000);
CALL SelectWhereAndMovie(100000);
CALL SelectEveryMovie(100000);
CALL UpdateWhereMovie(100000);
CALL UpdateEveryMovie(100000);
CALL DeleteEveryMovie(100000);

INSERT INTO Procedure_Log (Procedure_Name)
VALUES ('Scenario 3.2');

CALL InsertProductionStudios(1000000);
CALL InsertMovies(1000000);
CALL SelectWhereMovies(1000000);
CALL SelectWhereAndMovie(1000000);
CALL SelectEveryMovie(1000000);
CALL UpdateWhereMovie(1000000);
CALL UpdateEveryMovie(1000000);
CALL DeleteEveryMovie(1000000);

DROP INDEX idx_release_year_rating ON Movie;
CREATE INDEX idx_release_year_rating ON Movie (Release_Year, Rating);

INSERT INTO Procedure_Log (Procedure_Name)
VALUES ('Scenario 4.1');

CALL InsertProductionStudios(100000);
CALL InsertMovies(100000);
CALL SelectWhereMovies(100000);
CALL SelectWhereAndMovie(100000);
CALL SelectEveryMovie(100000);
CALL UpdateWhereMovie(100000);
CALL UpdateEveryMovie(100000);
CALL DeleteEveryMovie(100000);

INSERT INTO Procedure_Log (Procedure_Name)
VALUES ('Scenario 4.2');

CALL InsertProductionStudios(1000000);
CALL InsertMovies(1000000);
CALL SelectWhereMovies(1000000);
CALL SelectWhereAndMovie(1000000);
CALL SelectEveryMovie(1000000);
CALL UpdateWhereMovie(1000000);
CALL UpdateEveryMovie(1000000);
CALL DeleteEveryMovie(1000000);
SHOW INDEXES FROM Movie;

SELECT * FROM Procedure_Log;

#   Kakšne razlike v času izvajanja poizvedb opažate?
#	-----------------------------------------------------------------
#				    					S1 		S2	 	S3 		S4 	
# 		INSERT-STUDIO  		100.000		4	  	4	  	4	  	5	  	
# 		INSERT-STUDIO		1.000.000	34   	39  	41  	39	 	
#	-----------------------------------------------------------------
#		Opazimo, da je čas izvajanja INSERT UKAZA v NEODVISNO tabelo
#		dokaj hitra in ne glede na scenarij medseboj dokaj podobna.
#	-----------------------------------------------------------------
#				   						S1 		S2		S3		S4
# 		INSERT-MOVIE   		100.000	 	10	 	51	 	19	 	76	 	
# 		INSERT-MOVIE 		1.000.000	96		213		371		354		
#	-----------------------------------------------------------------
#		Opazimo, da je čas izvajanja INSERT UKAZA v ODVISNO tabelo
#		VIŠJA zaradi TUJEGA KLJUČA. Hkrati pa opazimo, da ima na čas
#		izvajanja velik vpliv tudi INDEX, ki močno zviša čas izvajanja.
#	-----------------------------------------------------------------
#				   						S1 		S2		S3		S4
# 		SELECT-WHERE  		100.000	  	0	  	1	  	0	  	0	  	
# 		SELECT-WHERE 		1.000.000	0	  	1	  	1   	1   	
#	-----------------------------------------------------------------
#				   						S1 		S2		S3		S4
# 		SELECT-WHERE-AND  	100.000	  	1	  	0	  	0	  	0	  	
# 		SELECT-WHERE-AND 	1.000.000	1	  	1	  	1   	1   	
#	-----------------------------------------------------------------
#				   						S1 		S2		S3		S4
# 		SELECT  			100.000	  	0	  	0	  	1	  	0	  	
# 		SELECT 				1.000.000	1	  	1	  	1   	1   	
#	-----------------------------------------------------------------
# 		Izvedba vseh SELECT ukazov je v mojem primeru bila praktično
#		izvedena v sklopu ene sekunde, ne glede na WHERE pogoj.
#	-----------------------------------------------------------------
#				   						S1 		S2		S3		S4
# 		UPDATE_WHERE  		100.000	  	0	  	0	  	1	  	1	  	
# 		UPDATE_WHERE 		1.000.000	4	  	5	  	4   	5   	
#	-----------------------------------------------------------------
# 		Izvedba UPDATE z WHERE pogojem je pravtako ostala
#		med scenariji nespremenjena.
#	-----------------------------------------------------------------
#				   						S1 		S2		S3		S4
# 		UPDATE  			100.000	  	1	  	4	  	1	  	1	  	
# 		UPDATE 				1.000.000	14	  	18	  	18   	17   	
#	-----------------------------------------------------------------
# 		Izvedba UPDATE pa je bila višja le v scenariju 2, kjer ni bil
#		uporabljen ne INDEX ne TUJI KLJUČ.
#	-----------------------------------------------------------------
#				   						S1 		S2		S3		S4
# 		DELETE  			100.000	  	1	  	9	  	3	  	3	  	
# 		DELETE 				1.000.000	62	  	71	  	67   	68   	
#	-----------------------------------------------------------------
# 		Enako velja pri izvedbi DELETE, ki se je izvajal dlje časa le 
#		v scenariju 2, kjer ni bil uporabljen ne INDEX ne TUJI KLJUČ.
#	-----------------------------------------------------------------

#   Ali v vašem primeru obstajajo razlike v času izvajanja poizvedb, 
#	kadar omejitev tujega ključa uporabimo in kadar ne? Zakaj da/ne?
#	-----------------------------------------------------------------
#		Čas izvajanja se pri INSERT-MOVIES brez omejitev tujih ključev
#		bistveno podaljša, kar je nepričakovano. Predvidevam, da
#		MySQL oz. MySQL Workbench ter sama baza še vedno hrani neke
#		podatke o tujem ključu, kar povzroči daljše izvajanje tudi,
#		če tuj ključ ne obstaja več.

#		Enako velja za DELETE-MOVIES, kjer se čas izvajanja podaljša 
#		pri scenariju brez omejitev tujih ključev.
#	-----------------------------------------------------------------

#   Ali v vašem primeru obstajajo razlike v času izvajanja poizvedb, 
#	kadar ne uporabljamo indeksa, kadar uporabimo enostaven indeks 
#	in kadar uporabimo sestavljen indeks? Zakaj da/ne?
#	-----------------------------------------------------------------
#		Čas izvajanja INSERT-MOVIES se je podaljšal, ko smo vpeljali
#		dodatna indexa, saj poleg tabel zdaj skrbi še za indeksno 
#		tabelo. 

#		Poizvedbe SELECT med seboj niso imele nekakšnih drastičnih
#		razlik, verjetno zaradi vsebinske preprostosti.

#		Ukazi UPDATE in DELETE pa so v primeru uporabe indeksov daljše
#		saj zahtevajo posodabljanje oz. preverjanje pripadajočih 
#		indeksov kot tudi samih tabel.
#	-----------------------------------------------------------------

#	Ugotovimo, da tuji ključi nimajo vedno vpliva na hitrost in lahko
#	tudi škodijo, indeksi v nasprotju pa lahko pohitrijo SELECT 
#	poizvedbe a upočasnijo INSERT, UPDATE in DELETE ukaze. 
#	Pravtako opazimo, da imajo sestavljeni indeksi večji vpliv na čas 
#	izvajanja, kot enostavni indeksi.
#	-----------------------------------------------------------------
