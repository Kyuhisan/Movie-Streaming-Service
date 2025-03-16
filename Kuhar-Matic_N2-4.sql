use mydbNormalized;
SET @OLD_SAFE_UPDATES = @@SQL_SAFE_UPDATES;
SET SQL_SAFE_UPDATES = 0;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS Procedure_Log_Normalized (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Procedure_Name VARCHAR(255),
    Start_Time DATETIME(6),
    End_Time DATETIME(6),
    Duration_Miliseconds DECIMAL(13,3),
    Num_Records INT
);

TRUNCATE TABLE Actor;
TRUNCATE TABLE Actor_Movie;
TRUNCATE TABLE Award;
TRUNCATE TABLE Director;
TRUNCATE TABLE Director_Movie;
TRUNCATE TABLE Genre;
TRUNCATE TABLE Movie;
TRUNCATE TABLE Movie_Award;
TRUNCATE TABLE Movie_Genre;
TRUNCATE TABLE Person;
TRUNCATE TABLE Production_Studio;
TRUNCATE TABLE Review;
TRUNCATE TABLE Subscription;
TRUNCATE TABLE User_Profile;
TRUNCATE TABLE Procedure_Log_Normalized;

##------------------------------------
##	SELECTS
##------------------------------------
DROP PROCEDURE IF EXISTS SelectDirectorsByStatus;
DROP PROCEDURE IF EXISTS SelectMoviesByGenre;
DROP PROCEDURE IF EXISTS SelectMovieStudioName;
DROP PROCEDURE IF EXISTS SelectAllMaleUserProfiles;

DELIMITER //
CREATE PROCEDURE SelectDirectorsByStatus(IN num_records INT)
BEGIN
    DECLARE start_time DATETIME(6);
    DECLARE end_time DATETIME(6);
    DECLARE duration DECIMAL(13,3);
    
	SET start_time = NOW(6);
    
    START TRANSACTION;
		SELECT ID_Director_Movie, FK_Movie, FK_Person, Directing_Status FROM Director 
        JOIN Person ON ID_Person = FK_Person
        JOIN Director_Movie ON ID_Director = FK_Director
        WHERE Directing_Status = 'Active';
	COMMIT;
    
	SET end_time = NOW(6);
    SET duration = TIMESTAMPDIFF(MICROSECOND, start_time, end_time) / 1000;
	INSERT INTO Procedure_Log_Normalized (Procedure_Name, Start_Time, End_Time, Duration_Miliseconds, Num_Records)
    VALUES ('PODVAJANJE NEKLJUČNIH 1:M - SELECT DIRECTORS BY STATUS', start_time, end_time, duration, num_records);
END //

CREATE PROCEDURE SelectMoviesByGenre(IN num_records INT)
BEGIN
    DECLARE start_time DATETIME(6);
    DECLARE end_time DATETIME(6);
    DECLARE duration DECIMAL(13,3);
    
	SET start_time = NOW(6);
    
    START TRANSACTION;
		SELECT M.ID_Movie, M.Title, M.Release_Year, G.Genre FROM Movie M
        JOIN Movie_Genre MG ON M.ID_Movie = MG.FK_Movie 
        JOIN Genre G ON MG.FK_Genre = G.ID_Genre
        WHERE G.Genre = 'Action' OR G.Genre = 'Comedy' OR G.Genre = 'Horror';
	COMMIT;
    
	SET end_time = NOW(6);
    SET duration = TIMESTAMPDIFF(MICROSECOND, start_time, end_time) / 1000;
	INSERT INTO Procedure_Log_Normalized (Procedure_Name, Start_Time, End_Time, Duration_Miliseconds, Num_Records)
    VALUES ('PONAVLJUJOČE SKUPINE - SELECT MOVIES BY GENRE', start_time, end_time, duration, num_records);
END //

CREATE PROCEDURE SelectMovieStudioName(IN num_records INT)
BEGIN
    DECLARE start_time DATETIME(6);
    DECLARE end_time DATETIME(6);
    DECLARE duration DECIMAL(13,3);
    
	SET start_time = NOW(6);
    
    START TRANSACTION;
		SELECT M.*, Studio_Name FROM Movie M
        JOIN Production_Studio ON FK_Production_Studio = ID_Production_Studio;
	COMMIT;
    
	SET end_time = NOW(6);
    SET duration = TIMESTAMPDIFF(MICROSECOND, start_time, end_time) / 1000;
	INSERT INTO Procedure_Log_Normalized (Procedure_Name, Start_Time, End_Time, Duration_Miliseconds, Num_Records)
    VALUES ('PODVAJANJE NEKLJUČNIH 1:M - SELECT MOVIE STUDIO NAME', start_time, end_time, duration, num_records);
END //

CREATE PROCEDURE SelectAllMaleUserProfiles(IN num_records INT)
BEGIN
    DECLARE start_time DATETIME(6);
    DECLARE end_time DATETIME(6);
    DECLARE duration DECIMAL(13,3);
    
	SET start_time = NOW(6);
    
    START TRANSACTION;
		SELECT p.ID_Person, p.First_Name, p.Last_Name, p.Date_Of_Birth, p.Place_Of_Birth, p.Gender, u.Username,	u.Email, u.Phone_Number, u.Age_Restriction
		FROM mydbNormalized.Person p
		LEFT JOIN mydbNormalized.User_Profile u ON p.ID_Person = u.FK_Person
		WHERE p.Gender = 'Male';
	COMMIT;
    
	SET end_time = NOW(6);
    SET duration = TIMESTAMPDIFF(MICROSECOND, start_time, end_time) / 1000;
	INSERT INTO Procedure_Log_Normalized (Procedure_Name, Start_Time, End_Time, Duration_Miliseconds, Num_Records)
    VALUES ('ZDRUŽEVANJE RELACIJ - SELECT MALE PROFILES', start_time, end_time, duration, num_records);
END //
DELIMITER ;

INSERT INTO Procedure_Log_Normalized (Procedure_Name)
VALUES ('Scenario 1.1');
CALL InsertProductionStudios(5000);
CALL InsertMovies(5000);
CALL InsertPersons(5000);
CALL InsertActors(5000);
CALL InsertActorsInMovies(5000);
CALL InsertReviews(5000);
CALL InsertAwards(5000);
CALL InsertMovieAwards(5000);
CALL InsertDirectors(5000);
CALL InsertDirectorsInMovies(5000);
CALL InsertGenres();
CALL InsertMovieGenres(5000);
CALL InsertSubscriptions(5000);
CALL InsertUserProfiles(5000);
CALL SelectDirectorsByStatus(5000);
CALL SelectMoviesByGenre(5000);
CALL SelectMovieStudioName(5000);
CALL SelectAllMaleUserProfiles(5000);

TRUNCATE TABLE Actor;
TRUNCATE TABLE Actor_Movie;
TRUNCATE TABLE Award;
TRUNCATE TABLE Director;
TRUNCATE TABLE Director_Movie;
TRUNCATE TABLE Genre;
TRUNCATE TABLE Movie;
TRUNCATE TABLE Movie_Award;
TRUNCATE TABLE Movie_Genre;
TRUNCATE TABLE Person;
TRUNCATE TABLE Production_Studio;
TRUNCATE TABLE Review;
TRUNCATE TABLE Subscription;
TRUNCATE TABLE User_Profile;

INSERT INTO Procedure_Log_Normalized (Procedure_Name)
VALUES ('Scenario 2.1');
CALL InsertProductionStudios(20000);
CALL InsertMovies(20000);
CALL InsertPersons(20000);
CALL InsertActors(20000);
CALL InsertActorsInMovies(20000);
CALL InsertReviews(20000);
CALL InsertAwards(20000);
CALL InsertMovieAwards(20000);
CALL InsertDirectors(20000);
CALL InsertDirectorsInMovies(20000);
CALL InsertGenres();
CALL InsertMovieGenres(20000);
CALL InsertSubscriptions(20000);
CALL InsertUserProfiles(20000);
CALL SelectDirectorsByStatus(20000);
CALL SelectMoviesByGenre(20000);
CALL SelectMovieStudioName(20000);
CALL SelectAllMaleUserProfiles(20000);

SELECT Procedure_Name, Duration_Miliseconds FROM Procedure_Log_Normalized;
SET FOREIGN_KEY_CHECKS = 1;
SET SQL_SAFE_UPDATES = @OLD_SAFE_UPDATES;

##---------------------------------------------------------------------
##---------------------------------------------------------------------
##	DENORMALIZED
##---------------------------------------------------------------------
##---------------------------------------------------------------------
use mydbDenormalized;
SET @OLD_SAFE_UPDATES = @@SQL_SAFE_UPDATES;
SET SQL_SAFE_UPDATES = 0;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS Procedure_Log_Denormalized (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Procedure_Name VARCHAR(255),
    Start_Time DATETIME(6),
    End_Time DATETIME(6),
    Duration_Miliseconds DECIMAL(13,3),
    Num_Records INT
);

TRUNCATE TABLE Actor_Movie;
TRUNCATE TABLE Award;
TRUNCATE TABLE Director_Movie;
TRUNCATE TABLE Genre;
TRUNCATE TABLE Movie;
TRUNCATE TABLE Movie_Award;
TRUNCATE TABLE Movie_Genre;
TRUNCATE TABLE Person;
TRUNCATE TABLE Production_Studio;
TRUNCATE TABLE Subscription;
TRUNCATE TABLE Procedure_Log_Denormalized;

##------------------------------------
##	SELECTS
##------------------------------------
DROP PROCEDURE IF EXISTS SelectDirectorsByStatus;
DROP PROCEDURE IF EXISTS SelectMoviesByGenre;
DROP PROCEDURE IF EXISTS SelectMovieStudioName;
DROP PROCEDURE IF EXISTS SelectAllMaleUserProfiles;

DELIMITER //
CREATE PROCEDURE SelectDirectorsByStatus(IN num_records INT)
BEGIN
    DECLARE start_time DATETIME(6);
    DECLARE end_time DATETIME(6);
    DECLARE duration DECIMAL(13,3);
    
	SET start_time = NOW(6);
    
    START TRANSACTION;
		SELECT * FROM Director_Movie
        WHERE Directing_Status = 'Active';
	COMMIT;
    
	SET end_time = NOW(6);
    SET duration = TIMESTAMPDIFF(MICROSECOND, start_time, end_time) / 1000;
	INSERT INTO Procedure_Log_Denormalized (Procedure_Name, Start_Time, End_Time, Duration_Miliseconds, Num_Records)
    VALUES ('PODVAJANJE NEKLJUČNIH 1:M - SELECT DIRECTORS BY STATUS', start_time, end_time, duration, num_records);
END //

CREATE PROCEDURE SelectMoviesByGenre(IN num_records INT)
BEGIN
    DECLARE start_time DATETIME(6);
    DECLARE end_time DATETIME(6);
    DECLARE duration DECIMAL(13,3);
    
	SET start_time = NOW(6);
    
    START TRANSACTION;
		SELECT ID_Movie, Title, Release_Year, Primary_Genre FROM Movie
        WHERE Primary_Genre = 'Action' OR JSON_CONTAINS(Secondary_Genres, '"Horror"') OR JSON_CONTAINS(Secondary_Genres, '"Comedy"');
	COMMIT;
    
	SET end_time = NOW(6);
    SET duration = TIMESTAMPDIFF(MICROSECOND, start_time, end_time) / 1000;
	INSERT INTO Procedure_Log_Denormalized (Procedure_Name, Start_Time, End_Time, Duration_Miliseconds, Num_Records)
    VALUES ('PONAVLJUJOČE SKUPINE - SELECT MOVIES BY GENRE', start_time, end_time, duration, num_records);
END //

CREATE PROCEDURE SelectMovieStudioName(IN num_records INT)
BEGIN
    DECLARE start_time DATETIME(6);
    DECLARE end_time DATETIME(6);
    DECLARE duration DECIMAL(13,3);
    
	SET start_time = NOW(6);
    
    START TRANSACTION;
		SELECT title, release_Date, release_year, Length, Movie_Description, Average_Score, FK_Production_Studio, studio_Name FROM Movie;
	COMMIT;
    
	SET end_time = NOW(6);
    SET duration = TIMESTAMPDIFF(MICROSECOND, start_time, end_time) / 1000;
	INSERT INTO Procedure_Log_Denormalized (Procedure_Name, Start_Time, End_Time, Duration_Miliseconds, Num_Records)
    VALUES ('PODVAJANJE NEKLJUČNIH 1:M - SELECT MOVIE STUDIO NAME', start_time, end_time, duration, num_records);
END //

CREATE PROCEDURE SelectAllMaleUserProfiles(IN num_records INT)
BEGIN
    DECLARE start_time DATETIME(6);
    DECLARE end_time DATETIME(6);
    DECLARE duration DECIMAL(13,3);
    
	SET start_time = NOW(6);
    
    START TRANSACTION;
		SELECT p.ID_Person, p.First_Name, p.Last_Name, p.Date_Of_Birth, p.Place_Of_Birth, p.Gender, p.Username,	p.Email, p.Phone_Number, p.Age_Restriction FROM mydbDenormalized.Person p
		WHERE p.Gender = 'Male';
	COMMIT;
    
	SET end_time = NOW(6);
    SET duration = TIMESTAMPDIFF(MICROSECOND, start_time, end_time) / 1000;
	INSERT INTO Procedure_Log_Denormalized (Procedure_Name, Start_Time, End_Time, Duration_Miliseconds, Num_Records)
    VALUES ('ZDRUŽEVANJE RELACIJ - SELECT MALE PROFILES', start_time, end_time, duration, num_records);
END //
DELIMITER ;

INSERT INTO Procedure_Log_Denormalized (Procedure_Name)
VALUES ('Scenario 1.2');
CALL InsertProductionStudios(5000);
CALL InsertGenres();
CALL InsertMovies(5000);
CALL InsertMovieGenres(5000);
CALL InsertReviews(5000);
CALL InsertAwards(5000);
CALL InsertMovieAwards(5000);
CALL InsertSubscriptions(5000);
CALL InsertPeople(5000);
CALL UpdateMovieRatings();
CALL SelectDirectorsByStatus(5000);
CALL SelectMoviesByGenre(5000);
CALL SelectMovieStudioName(5000);
CALL SelectAllMaleUserProfiles(5000);

TRUNCATE TABLE Actor_Movie;
TRUNCATE TABLE Award;
TRUNCATE TABLE Director_Movie;
TRUNCATE TABLE Genre;
TRUNCATE TABLE Movie;
TRUNCATE TABLE Movie_Award;
TRUNCATE TABLE Movie_Genre;
TRUNCATE TABLE Person;
TRUNCATE TABLE Production_Studio;
TRUNCATE TABLE Subscription;

INSERT INTO Procedure_Log_Denormalized (Procedure_Name)
VALUES ('Scenario 2.2');
CALL InsertProductionStudios(20000);
CALL InsertGenres();
CALL InsertMovies(20000);
CALL InsertMovieGenres(20000);
CALL InsertReviews(20000);
CALL InsertAwards(20000);
CALL InsertMovieAwards(20000);
CALL InsertSubscriptions(20000);
CALL InsertPeople(20000);
CALL UpdateMovieRatings();
CALL SelectDirectorsByStatus(20000);
CALL SelectMoviesByGenre(20000);
CALL SelectMovieStudioName(20000);
CALL SelectAllMaleUserProfiles(20000);

SELECT Procedure_Name, Duration_Miliseconds FROM Procedure_Log_Denormalized;
SET FOREIGN_KEY_CHECKS = 1;
SET SQL_SAFE_UPDATES = 1;
SET SQL_SAFE_UPDATES = @OLD_SAFE_UPDATES;

#	1. Kakšne razlike v času izvajanja poizvedb opažate? 
#		Opazim, da vnašanje podatkov načeloma traja dlje časa ampak so hitrosti poizvedb dokaj hitrejše.
#---------------------------------------------------------------------
#	NORMALIZED
#---------------------------------------------------------------------
#	Scenario 1.1	
#	PODVAJANJE NEKLJUČNIH 1:M 	- SELECT DIRECTORS BY STATUS	10.447
#	PONAVLJUJOČE SKUPINE 		- SELECT MOVIES BY GENRE		3.327
#	PODVAJANJE NEKLJUČNIH 1:M 	- SELECT MOVIE STUDIO NAME		14.396
#	ZDRUŽEVANJE RELACIJ 		- SELECT MALE PROFILES			9.663
#	Scenario 2.1	
#	PODVAJANJE NEKLJUČNIH 1:M 	- SELECT DIRECTORS BY STATUS	35.878
#	PONAVLJUJOČE SKUPINE 		- SELECT MOVIES BY GENRE		14.708
#	PODVAJANJE NEKLJUČNIH 1:M 	- SELECT MOVIE STUDIO NAME		55.983
#	ZDRUŽEVANJE RELACIJ 		- SELECT MALE PROFILES			48.105

#---------------------------------------------------------------------
#	DENORMALIZED
#---------------------------------------------------------------------
#	Scenario 2.1	
#	PODVAJANJE NEKLJUČNIH 1:M 	- SELECT DIRECTORS BY STATUS	0.545
#	PONAVLJUJOČE SKUPINE 		- SELECT MOVIES BY GENRE		9.778
#	PODVAJANJE NEKLJUČNIH 1:M 	- SELECT MOVIE STUDIO NAME		8.299
#	ZDRUŽEVANJE RELACIJ 		- SELECT MALE PROFILES			3.584
#	Scenario 2.2	
#	PODVAJANJE NEKLJUČNIH 1:M 	- SELECT DIRECTORS BY STATUS	1.593
#	PONAVLJUJOČE SKUPINE 		- SELECT MOVIES BY GENRE		38.077
#	PODVAJANJE NEKLJUČNIH 1:M 	- SELECT MOVIE STUDIO NAME		19.525
#	ZDRUŽEVANJE RELACIJ 		- SELECT MALE PROFILES			11.797

#	2. Ali obstajajo razlike v času izvajanja poizvedb med normalizirano in denormalizirano podatkovno bazo?
#		V mojem primeru so 3/4 načinov denormalizacije hitrejši pri času izvajanja poizvedb. 
#		Edini primer kjer so poizvedbe počasnejše pri denormalizirani obliki je v primeru ponavljajočih skupin
#		zaradi vpeljave JSON atributnega tipa, ki zahteva še dodatno notranjo poizvedbo po JSON vsebini

#	3. Zakaj da/ne?
#		Poizvedbe so zaradi denormalizacije, ki združi ponavljajoče in pomembne atribute oz. entitete dosti hitrejšexecute
#		saj niso odvisne od drugih tabel oz. odvisnosti z tujimi ključi. Podatki se vnašajo sicer bolj dolgo zaradi podvajanj
#		in sinhronizacije ampak so poizvedbe zato dosti hitrejše. (Poleg tega pa bomo redko kdaj vnesli takšno količino podatkov
#		hkrati zato vpliv na vstavljanje podatkov v bazo ni tako velik).