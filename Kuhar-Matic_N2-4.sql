use mydbNormalized;
SET @OLD_SAFE_UPDATES = @@SQL_SAFE_UPDATES;
SET SQL_SAFE_UPDATES = 0;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS Procedure_Log_Normalized (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Procedure_Name VARCHAR(100000),
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
CALL InsertProductionStudios(100000);
CALL InsertMovies(100000);
CALL InsertPersons(100000);
CALL InsertActors(100000);
CALL InsertActorsInMovies(100000);
CALL InsertReviews(100000);
CALL InsertAwards(100000);
CALL InsertMovieAwards(100000);
CALL InsertDirectors(100000);
CALL InsertDirectorsInMovies(100000);
CALL InsertGenres();
CALL InsertMovieGenres(100000);
CALL InsertSubscriptions(100000);
CALL InsertUserProfiles(100000);
CALL SelectDirectorsByStatus(100000);
CALL SelectMoviesByGenre(100000);
CALL SelectMovieStudioName(100000);
CALL SelectAllMaleUserProfiles(100000);

INSERT INTO Procedure_Log_Normalized (Procedure_Name)
VALUES ('Scenario 2.1');
CALL InsertProductionStudios(1000000);
CALL InsertMovies(1000000);
CALL InsertPersons(1000000);
CALL InsertActors(1000000);
CALL InsertActorsInMovies(1000000);
CALL InsertReviews(1000000);
CALL InsertAwards(1000000);
CALL InsertMovieAwards(1000000);
CALL InsertDirectors(1000000);
CALL InsertDirectorsInMovies(1000000);
CALL InsertGenres();
CALL InsertMovieGenres(1000000);
CALL InsertSubscriptions(1000000);
CALL InsertUserProfiles(1000000);
CALL SelectDirectorsByStatus(1000000);
CALL SelectMoviesByGenre(1000000);
CALL SelectMovieStudioName(1000000);
CALL SelectAllMaleUserProfiles(1000000);

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
    Procedure_Name VARCHAR(100000),
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
CALL InsertProductionStudios(100000);
CALL InsertGenres();
CALL InsertMovies(100000);
CALL InsertMovieGenres(100000);
CALL InsertReviews(100000);
CALL InsertAwards(100000);
CALL InsertMovieAwards(100000);
CALL InsertSubscriptions(100000);
CALL InsertPeople(100000);
CALL UpdateMovieRatings();
CALL SelectDirectorsByStatus(100000);
CALL SelectMoviesByGenre(100000);
CALL SelectMovieStudioName(100000);
CALL SelectAllMaleUserProfiles(100000);

INSERT INTO Procedure_Log_Denormalized (Procedure_Name)
VALUES ('Scenario 2.2');
CALL InsertProductionStudios(1000000);
CALL InsertGenres();
CALL InsertMovies(1000000);
CALL InsertMovieGenres(1000000);
CALL InsertReviews(1000000);
CALL InsertAwards(1000000);
CALL InsertMovieAwards(1000000);
CALL InsertSubscriptions(1000000);
CALL InsertPeople(1000000);
CALL UpdateMovieRatings();
CALL SelectDirectorsByStatus(1000000);
CALL SelectMoviesByGenre(1000000);
CALL SelectMovieStudioName(1000000);
CALL SelectAllMaleUserProfiles(1000000);

SELECT Procedure_Name, Duration_Miliseconds FROM Procedure_Log_Denormalized;
SET FOREIGN_KEY_CHECKS = 1;
SET SQL_SAFE_UPDATES = 1;
SET SQL_SAFE_UPDATES = @OLD_SAFE_UPDATES;