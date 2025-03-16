use mydbnormalized;
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE Actor_Movie;
TRUNCATE TABLE Director_Movie;
TRUNCATE TABLE Movie_Genre;
TRUNCATE TABLE Review;
TRUNCATE TABLE Movie_Award;
TRUNCATE TABLE User_Profile;
TRUNCATE TABLE Subscription;
TRUNCATE TABLE Award;
TRUNCATE TABLE Actor;
TRUNCATE TABLE Director;
TRUNCATE TABLE Person;
TRUNCATE TABLE Movie;
TRUNCATE TABLE Genre;
TRUNCATE TABLE Production_Studio;
SET FOREIGN_KEY_CHECKS = 1;

DROP PROCEDURE IF EXISTS InsertProductionStudios;
DROP PROCEDURE IF EXISTS InsertMovies;
DROP PROCEDURE IF EXISTS InsertPersons;
DROP PROCEDURE IF EXISTS InsertActors;
DROP PROCEDURE IF EXISTS InsertReviews;
DROP PROCEDURE IF EXISTS InsertAwards;
DROP PROCEDURE IF EXISTS InsertDirectors;
DROP PROCEDURE IF EXISTS InsertActorsInMovies;
DROP PROCEDURE IF EXISTS InsertMovieAwards;
DROP PROCEDURE IF EXISTS InsertDirectorsInMovies;
DROP PROCEDURE IF EXISTS InsertMovieGenres;
DROP PROCEDURE IF EXISTS InsertUserProfiles;
DROP PROCEDURE IF EXISTS InsertSubscriptions;
DROP PROCEDURE IF EXISTS InsertGenres;
DROP PROCEDURE IF EXISTS UpdateMovieRatings;

DELIMITER //

CREATE PROCEDURE InsertProductionStudios(IN num_records INT)
BEGIN
    DECLARE i INT DEFAULT 0;
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
END //

CREATE PROCEDURE InsertPersons(IN num_records INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    
    START TRANSACTION;
    WHILE i < num_records DO
        INSERT INTO Person (First_Name, Last_Name, Date_Of_Birth, Place_Of_Birth, Gender)
        VALUES (
            ELT(FLOOR(1 + (RAND() * 50)), 
                'John', 'Michael', 'Emily', 'Sophia', 'David', 'Emma', 'James', 'Olivia', 'Daniel', 'Isabella',
                'William', 'Charlotte', 'Benjamin', 'Amelia', 'Alexander', 'Mia', 'Ethan', 'Harper', 'Henry', 'Evelyn',
                'Lucas', 'Abigail', 'Mason', 'Ella', 'Logan', 'Scarlett', 'Jackson', 'Grace', 'Aiden', 'Lily',
                'Sebastian', 'Chloe', 'Matthew', 'Victoria', 'Jack', 'Madison', 'Owen', 'Eleanor', 'Samuel', 'Hannah',
                'Joseph', 'Addison', 'Leo', 'Aubrey', 'Daniel', 'Zoe', 'Christopher', 'Stella', 'Isaac', 'Natalie'),
            
            ELT(FLOOR(1 + (RAND() * 50)), 
                'Smith', 'Johnson', 'Brown', 'Williams', 'Jones', 'Miller', 'Davis', 'Garcia', 'Martinez', 'Taylor',
                'Anderson', 'Thomas', 'Hernandez', 'Moore', 'Martin', 'Jackson', 'Thompson', 'White', 'Lopez', 'Lee',
                'Gonzalez', 'Harris', 'Clark', 'Lewis', 'Robinson', 'Walker', 'Perez', 'Hall', 'Young', 'Allen',
                'Sanchez', 'Wright', 'King', 'Scott', 'Green', 'Baker', 'Adams', 'Nelson', 'Hill', 'Ramirez',
                'Campbell', 'Mitchell', 'Carter', 'Roberts', 'Gomez', 'Phillips', 'Evans', 'Turner', 'Torres', 'Parker'),
            
            DATE_ADD('1940-01-01', INTERVAL RAND() * 30000 DAY),
            
            ELT(FLOOR(1 + (RAND() * 50)), 
                'New York', 'Los Angeles', 'Chicago', 'Houston', 'Miami', 'San Francisco', 'Dallas', 'Boston', 'Seattle', 'Denver',
                'Phoenix', 'Atlanta', 'Philadelphia', 'San Diego', 'Austin', 'Las Vegas', 'Orlando', 'Detroit', 'Minneapolis', 'Charlotte',
                'San Antonio', 'Portland', 'Indianapolis', 'Columbus', 'Baltimore', 'Salt Lake City', 'Tampa', 'St. Louis', 'Kansas City', 'Milwaukee',
                'Nashville', 'Cincinnati', 'Pittsburgh', 'Sacramento', 'Raleigh', 'Cleveland', 'Honolulu', 'Buffalo', 'New Orleans', 'Oklahoma City',
                'Louisville', 'Richmond', 'Boise', 'Anchorage', 'Charleston', 'Reno', 'Madison', 'Birmingham', 'Des Moines', 'Providence'),
            
            ELT(FLOOR(1 + (RAND() * 2)), 'Male', 'Female')
        );
        SET i = i + 1;
    END WHILE;
    COMMIT;
END //

CREATE PROCEDURE InsertDirectors(IN num_records INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE person_id INT;
    START TRANSACTION;
    WHILE i < num_records DO
        SELECT ID_Person INTO person_id FROM Person 
        WHERE ID_Person NOT IN (SELECT FK_Person FROM Director) 
        ORDER BY RAND() LIMIT 1;
        
        IF person_id IS NOT NULL THEN
            INSERT INTO Director (Directing_Status, FK_Person)
            VALUES (ELT(FLOOR(1 + (RAND() * 3)), "Active", "Retired", "Deceased"), person_id);
            SET i = i + 1;
        END IF;
    END WHILE;
    COMMIT;
END //

CREATE PROCEDURE InsertAwards(IN num_records INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    START TRANSACTION;
    WHILE i < num_records DO
        INSERT INTO Award (Award_Category, Award_Type)
        VALUES (ELT(FLOOR(1 + (RAND() * 5)), "Best Picture", "Best Director", "Best Actor", "Best Actress", "Best Cinematography"), 
                ELT(FLOOR(1 + (RAND() * 2)), "Oscar", "Golden Globe", "BAFTA"));
        SET i = i + 1;
    END WHILE;
    COMMIT;
END //

CREATE PROCEDURE InsertMovieAwards(IN num_records INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE award_id INT;
    DECLARE movie_id INT;
    START TRANSACTION;
    WHILE i < num_records DO
        SELECT ID_Award INTO award_id FROM Award ORDER BY RAND() LIMIT 1;
        SELECT ID_Movie INTO movie_id FROM Movie ORDER BY RAND() LIMIT 1;
        
        IF NOT EXISTS (SELECT 1 FROM Movie_Award WHERE FK_Award = award_id AND FK_Movie = movie_id) THEN
            INSERT INTO Movie_Award (FK_Award, FK_Movie)
            VALUES (award_id, movie_id);
            SET i = i + 1;
        END IF;
    END WHILE;
    COMMIT;
END //

CREATE PROCEDURE InsertGenres()
BEGIN
    START TRANSACTION;
    
    INSERT INTO Genre (Genre) VALUES 
		("Action"), ("Fantasy"), ("Sci-Fi"), ("Romance"), ("Drama"), ("Horror"), ("Thriller"), ("Mistery"), ("Crime");
    COMMIT;
END //

DELIMITER //
CREATE PROCEDURE InsertMovies(IN num_records INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE studio_id INT;
    DECLARE release_date DATE;
    DECLARE release_year INT;
    
    DECLARE min_id INT;
    DECLARE max_id INT;

    SELECT MIN(ID_Production_Studio), MAX(ID_Production_Studio) INTO min_id, max_id FROM Production_Studio;

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
END //

CREATE PROCEDURE UpdateMovieRatings()
BEGIN
    START TRANSACTION;
    
    UPDATE Movie 
    SET Rating = (
        SELECT IFNULL(AVG(Score), 0)
        FROM Review 
        WHERE Review.FK_Movie = Movie.ID_Movie
    );

    COMMIT;
END //

CREATE PROCEDURE InsertActors(IN num_records INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE person_id INT;
    START TRANSACTION;
    WHILE i < num_records DO
        SELECT ID_Person INTO person_id FROM Person 
        WHERE ID_Person NOT IN (SELECT FK_Person FROM Actor) 
        ORDER BY RAND() LIMIT 1;
        
        IF person_id IS NOT NULL THEN
            INSERT INTO Actor (Stage_Name, Acting_Status, FK_Person)
            VALUES (CONCAT('StageName_', i), ELT(FLOOR(1 + (RAND() * 3)), "Active", "Retired", "Deceased"), person_id);
            SET i = i + 1;
        END IF;
    END WHILE;
    COMMIT;
END //

CREATE PROCEDURE InsertActorsInMovies(IN num_records INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE actor_id INT;
    DECLARE movie_id INT;
    START TRANSACTION;
    WHILE i < num_records DO
        SELECT ID_Actor INTO actor_id FROM Actor ORDER BY RAND() LIMIT 1;
        SELECT ID_Movie INTO movie_id FROM Movie ORDER BY RAND() LIMIT 1;
        
        IF NOT EXISTS (SELECT 1 FROM Actor_Movie WHERE FK_Actor = actor_id AND FK_Movie = movie_id) THEN
            INSERT INTO Actor_Movie (FK_Actor, FK_Movie)
            VALUES (actor_id, movie_id);
            SET i = i + 1;
        END IF;
    END WHILE;
    COMMIT;
END //

CREATE PROCEDURE InsertSubscriptions(IN num_records INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE subscription_type VARCHAR(20);
    DECLARE monthly_price FLOAT;
    DECLARE start_date DATE;
    DECLARE expiry_date DATE;
    DECLARE months_duration INT;
    DECLARE subscription_price FLOAT;

    START TRANSACTION;
    WHILE i < num_records DO
        SET subscription_type = ELT(FLOOR(1 + (RAND() * 3)), "Standard", "Premium", "Family");
        CASE 
            WHEN subscription_type = "Standard" THEN SET monthly_price = 10;
            WHEN subscription_type = "Premium" THEN SET monthly_price = 20;
            WHEN subscription_type = "Family" THEN SET monthly_price = 30;
        END CASE;

        SET start_date = DATE_ADD('2015-01-01', INTERVAL RAND() * 3000 DAY);
        SET months_duration = FLOOR(1 + (RAND() * 24));
        SET expiry_date = DATE_ADD(start_date, INTERVAL months_duration MONTH);
        SET subscription_price = monthly_price * months_duration;

        INSERT INTO Subscription (Monthly_Price, Subscription_Price, Subscription_Type, Subscription_Description, Start_Date, Expiry_Date)
        VALUES (
            monthly_price,
            subscription_price,
            subscription_type,
            CONCAT('Description for ', subscription_type, ' subscription ', i),
            start_date,
            expiry_date
        );

        SET i = i + 1;
    END WHILE;

    COMMIT;
END //

CREATE PROCEDURE InsertUserProfiles(IN num_records INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE person_id INT;
    DECLARE subscription_id INT;
    DECLARE available_persons INT;
    DECLARE unique_username VARCHAR(100);
    DECLARE unique_email VARCHAR(100);
    DECLARE username_exists INT DEFAULT 1;
    DECLARE email_exists INT DEFAULT 1;
    DECLARE person_age INT;
    DECLARE age_restriction ENUM('Kids', 'Underaged', 'Adult');
    DECLARE phone_prefix VARCHAR(10);
    DECLARE phone_number VARCHAR(15);

    START TRANSACTION;    
    SELECT COUNT(*) INTO available_persons FROM Person 
    WHERE ID_Person NOT IN (SELECT FK_Person FROM User_Profile);

    WHILE i < num_records AND available_persons > 0 DO
        SELECT ID_Person, TIMESTAMPDIFF(YEAR, Date_Of_Birth, CURDATE()) INTO person_id, person_age
        FROM Person 
        WHERE ID_Person NOT IN (SELECT FK_Person FROM User_Profile)
        ORDER BY RAND() LIMIT 1;

        IF person_id IS NOT NULL THEN
            IF person_age < 9 THEN
                SET age_restriction = 'Kids';
            ELSEIF person_age >= 9 AND person_age < 18 THEN
                SET age_restriction = 'Underaged';
            ELSE
                SET age_restriction = 'Adult';
            END IF;

            IF RAND() < 0.8 THEN
                SELECT ID_Subscription INTO subscription_id FROM Subscription ORDER BY RAND() LIMIT 1;
            ELSE
                SET subscription_id = NULL;
            END IF;

            SET phone_prefix = ELT(FLOOR(1 + (RAND() * 10)), 
                                   '+1', '+44', '+33', '+49', '+34', 
                                   '+39', '+81', '+61', '+55', '+91'); 
            SET phone_number = CONCAT(phone_prefix, FLOOR(100000000 + (RAND() * 900000000)));

            SET unique_username = CONCAT('User_', person_id);
            SET username_exists = 1;
            WHILE username_exists > 0 DO
                SELECT COUNT(*) INTO username_exists FROM User_Profile WHERE Username = unique_username;
                IF username_exists > 0 THEN
                    SET unique_username = CONCAT('User_', person_id, '_', FLOOR(RAND() * 10000));
                END IF;
            END WHILE;

            SET unique_email = CONCAT('user', person_id, '@email.com');
            SET email_exists = 1;
            WHILE email_exists > 0 DO
                SELECT COUNT(*) INTO email_exists FROM User_Profile WHERE Email = unique_email;
                IF email_exists > 0 THEN
                    SET unique_email = CONCAT('user', person_id, '_', FLOOR(RAND() * 10000), '@email.com');
                END IF;
            END WHILE;

            INSERT INTO User_Profile (Username, Password, Email, Phone_Number, Age_Restriction, FK_Subscription, FK_Person)
            VALUES (unique_username, 
                    CONCAT('Pass_', i),
                    unique_email,
                    phone_number,
                    age_restriction,
                    subscription_id,
                    person_id);

            SET i = i + 1;
        END IF;

        SELECT COUNT(*) INTO available_persons FROM Person 
        WHERE ID_Person NOT IN (SELECT FK_Person FROM User_Profile);
    END WHILE;

    COMMIT;
END //

CREATE PROCEDURE InsertMovieGenres(IN num_records INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE genre_id INT;
    DECLARE movie_id INT;
    START TRANSACTION;
    WHILE i < num_records DO
        SELECT ID_Genre INTO genre_id FROM Genre ORDER BY RAND() LIMIT 1;
        SELECT ID_Movie INTO movie_id FROM Movie ORDER BY RAND() LIMIT 1;
        
        IF NOT EXISTS (SELECT 1 FROM Movie_Genre WHERE FK_Genre = genre_id AND FK_Movie = movie_id) THEN
            INSERT INTO Movie_Genre (FK_Genre, FK_Movie)
            VALUES (genre_id, movie_id);
            SET i = i + 1;
        END IF;
    END WHILE;
    COMMIT;
END //

CREATE PROCEDURE InsertReviews(IN num_records INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE movie_id INT;
    START TRANSACTION;
    WHILE i < num_records DO
        SELECT ID_Movie INTO movie_id FROM Movie ORDER BY RAND() LIMIT 1;
        INSERT INTO Review (Score, Comment, FK_Movie)
        VALUES (FLOOR(1 + (RAND() * 10)), 
                CONCAT('Review comment ', i), 
                movie_id);
        SET i = i + 1;
    END WHILE;
    COMMIT;
END //

CREATE PROCEDURE InsertDirectorsInMovies(IN num_records INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE director_id INT;
    DECLARE movie_id INT;
    START TRANSACTION;
    WHILE i < num_records DO
        SELECT ID_Director INTO director_id FROM Director ORDER BY RAND() LIMIT 1;
        SELECT ID_Movie INTO movie_id FROM Movie ORDER BY RAND() LIMIT 1;
        
        IF NOT EXISTS (SELECT 1 FROM Director_Movie WHERE FK_Director = director_id AND FK_Movie = movie_id) THEN
            INSERT INTO Director_Movie (FK_Director, FK_Movie)
            VALUES (director_id, movie_id);
            SET i = i + 1;
        END IF;
    END WHILE;
    COMMIT;
END //
DELIMITER ;

-- Klic procedur za vstavljanje podatkov
CALL InsertProductionStudios(1000);
CALL InsertMovies(1000);
CALL InsertPersons(1000);
CALL InsertActors(1000);
CALL InsertActorsInMovies(1000);
CALL InsertReviews(1000);
CALL InsertAwards(1000);
CALL InsertMovieAwards(1000);
CALL InsertDirectors(1000);
CALL InsertDirectorsInMovies(1000);
CALL InsertGenres();
CALL InsertMovieGenres(1000);
CALL InsertSubscriptions(1000);
CALL InsertUserProfiles(1000);
SET SQL_SAFE_UPDATES = 0;
CALL UpdateMovieRatings();
SET SQL_SAFE_UPDATES = 1;