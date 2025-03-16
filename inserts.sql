use mydbdenormalized;
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE Production_Studio;
TRUNCATE TABLE Review;
TRUNCATE TABLE Movie_Award;
TRUNCATE TABLE Award;
TRUNCATE TABLE Movie_Genre;
TRUNCATE TABLE Genre;
TRUNCATE TABLE Subscription;
TRUNCATE TABLE Movie;
TRUNCATE TABLE Person;
TRUNCATE TABLE Director_Movie;
TRUNCATE TABLE Actor_Movie;
SET FOREIGN_KEY_CHECKS = 1;

DROP PROCEDURE IF EXISTS InsertProductionStudios;
DROP PROCEDURE IF EXISTS InsertReviews;
DROP PROCEDURE IF EXISTS InsertMovieAwards;
DROP PROCEDURE IF EXISTS InsertAwards;
DROP PROCEDURE IF EXISTS InsertMovieGenres;
DROP PROCEDURE IF EXISTS InsertGenres;
DROP PROCEDURE IF EXISTS InsertSubscriptions;
DROP PROCEDURE IF EXISTS InsertMovies;
DROP PROCEDURE IF EXISTS UpdateMovieRatings;
DROP PROCEDURE IF EXISTS InsertPeople;
DROP PROCEDURE IF EXISTS InsertActorsInMovies;
DROP PROCEDURE IF EXISTS InsertDirectorsInMovies;

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

CREATE PROCEDURE InsertMovieAwards(IN num_records INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE award_id INT;
    DECLARE movie_id INT;
    DECLARE movie_count INT;

    START TRANSACTION;
    WHILE i < num_records DO
        SELECT ID_Award INTO award_id FROM Award ORDER BY RAND() LIMIT 1;
        SELECT ID_Movie INTO movie_id FROM Movie ORDER BY RAND() LIMIT 1;
        
        IF movie_id IS NOT NULL THEN
            INSERT INTO Movie_Award (FK_Award, FK_Movie)
            VALUES (award_id, movie_id);
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

CREATE PROCEDURE InsertGenres()
BEGIN
    START TRANSACTION;
    INSERT INTO Genre (Genre) VALUES 
		("Action"), ("Fantasy"), ("Sci-Fi"), ("Romance"), ("Drama"), ("Horror"), ("Thriller"), ("Mistery"), ("Crime"), ("Unknown");
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

CREATE PROCEDURE InsertMovies(IN num_records INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE studio_id INT;
    DECLARE release_date DATE;
    DECLARE release_year INT;
    DECLARE chosen_genre VARCHAR(50);
    DECLARE secondary_genres_json JSON;
    DECLARE secondary_genre VARCHAR(50);
    DECLARE min_id INT;
    DECLARE max_id INT;

    SELECT MIN(ID_Production_Studio), MAX(ID_Production_Studio) INTO min_id, max_id FROM Production_Studio;

    START TRANSACTION;
    WHILE i < num_records DO
        SET studio_id = (SELECT ID_Production_Studio FROM Production_Studio ORDER BY RAND() LIMIT 1);
        SET release_date = DATE_ADD('1950-01-01', INTERVAL RAND() * (YEAR(CURDATE()) - 1950) * 365 DAY);
        SET release_year = YEAR(release_date);

        INSERT INTO Movie (Title, Release_Year, Release_Date, Length, Movie_Description, Average_Score, Primary_Genre, Secondary_Genres, FK_Production_Studio)
        VALUES (
            CONCAT('Movie_', i), 
            release_year, 
            release_date, 
            SEC_TO_TIME(FLOOR(5400 + (RAND() * 3600))),
            'Some description about the movie.', 
            0.0,
            'Unknown',
            NULL,
            studio_id
        );

        SELECT Genre INTO chosen_genre FROM Genre 
        WHERE Genre IN ("Action", "Fantasy", "Sci-Fi", "Romance", "Drama", "Thriller", "Mistery", "Crime") 
        ORDER BY RAND() LIMIT 1;

        UPDATE Movie 
        SET Primary_Genre = chosen_genre
        WHERE ID_Movie = LAST_INSERT_ID();

        SET secondary_genres_json = '[]';

        IF RAND() < 0.5 THEN
            WHILE JSON_LENGTH(secondary_genres_json) < 2 DO
                SELECT Genre INTO secondary_genre FROM Genre 
                WHERE Genre <> chosen_genre AND Genre <> 'Unknown' 
                ORDER BY RAND() LIMIT 1;

                IF NOT JSON_CONTAINS(secondary_genres_json, JSON_QUOTE(secondary_genre)) THEN
                    SET secondary_genres_json = JSON_ARRAY_APPEND(secondary_genres_json, '$', secondary_genre);
                END IF;
            END WHILE;

            UPDATE Movie 
            SET Secondary_Genres = secondary_genres_json
            WHERE ID_Movie = LAST_INSERT_ID();
        END IF;

        SET i = i + 1;
    END WHILE;
    COMMIT;
END //

CREATE PROCEDURE UpdateMovieRatings()
BEGIN
    START TRANSACTION;
    
    UPDATE Movie 
    SET Average_Score = (
        SELECT IFNULL(AVG(Score), 0)
        FROM Review 
        WHERE Review.FK_Movie = Movie.ID_Movie
    );
    COMMIT;
END //

CREATE PROCEDURE InsertPeople(IN num_records INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE person_id INT;
    DECLARE movie_id INT;
    DECLARE subscription_id INT;
    DECLARE person_age INT;
    DECLARE age_restriction ENUM('Kids', 'Underaged', 'Adult');
    DECLARE phone_prefix VARCHAR(10);
    DECLARE phone_number VARCHAR(15);
    DECLARE unique_username VARCHAR(100);
    DECLARE unique_email VARCHAR(100);
    DECLARE acting_chance FLOAT;
    DECLARE directing_chance FLOAT;
    DECLARE user_chance FLOAT;
    DECLARE acting_status ENUM('Acting', 'Retired');
    DECLARE directing_status ENUM('Active', 'Retired');
    DECLARE stage_name VARCHAR(50);

    START TRANSACTION;

    WHILE i < num_records DO
        -- Insert Person
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

        -- Get Last Inserted Person ID
        SET person_id = LAST_INSERT_ID();
        
        -- Get a random Movie ID
        SELECT ID_Movie INTO movie_id FROM Movie ORDER BY RAND() LIMIT 1;

        -- Calculate chances for assigning roles
        SET acting_chance = RAND();
        SET directing_chance = RAND();
        SET user_chance = RAND();

        -- Assign as Actor (50% chance)
        IF acting_chance < 0.5 AND movie_id IS NOT NULL THEN
            SET acting_status = ELT(FLOOR(1 + (RAND() * 2)), "Acting", "Retired");
            SET stage_name = CONCAT(
                ELT(FLOOR(1 + (RAND() * 50)), 'John', 'Michael', 'Emily', 'Sophia', 'David', 'Emma', 'James', 'Olivia', 'Daniel', 'Isabella'),
                ' ',
                ELT(FLOOR(1 + (RAND() * 50)), 'Smith', 'Johnson', 'Brown', 'Williams', 'Jones', 'Miller', 'Davis', 'Garcia', 'Martinez', 'Taylor')
            );

            INSERT INTO Actor_Movie (FK_Person, FK_Movie, Acting_Status)
            VALUES (person_id, movie_id, acting_status);

            -- Update Person with stage name and acting status
            UPDATE Person 
            SET Stage_Name = stage_name, 
                Acting_Status = acting_status 
            WHERE ID_Person = person_id;
        END IF;

        -- Assign as Director (30% chance)
        IF directing_chance < 0.3 AND movie_id IS NOT NULL THEN
            SET directing_status = ELT(FLOOR(1 + (RAND() * 2)), "Active", "Retired");

            INSERT INTO Director_Movie (FK_Person, FK_Movie, Directing_Status)
            VALUES (person_id, movie_id, directing_status);

            -- Update Person with directing status
            UPDATE Person 
            SET Directing_Status = directing_status 
            WHERE ID_Person = person_id;
        END IF;

        -- Assign as User (60% chance)
        IF user_chance < 0.6 THEN
            -- Determine Age Restriction
            SELECT TIMESTAMPDIFF(YEAR, Date_Of_Birth, CURDATE()) INTO person_age FROM Person WHERE ID_Person = person_id;

            IF person_age < 9 THEN
                SET age_restriction = 'Kids';
            ELSEIF person_age >= 9 AND person_age < 18 THEN
                SET age_restriction = 'Underaged';
            ELSE
                SET age_restriction = 'Adult';
            END IF;

            -- Assign Subscription (80% chance to have a subscription)
            IF RAND() < 0.8 THEN
                SELECT ID_Subscription INTO subscription_id FROM Subscription ORDER BY RAND() LIMIT 1;
            ELSE
                SET subscription_id = NULL;
            END IF;

            -- Generate Phone Number
            SET phone_prefix = ELT(FLOOR(1 + (RAND() * 10)), 
                                   '+1', '+44', '+33', '+49', '+34', 
                                   '+39', '+81', '+61', '+55', '+91'); 
            SET phone_number = CONCAT(phone_prefix, FLOOR(100000000 + (RAND() * 900000000)));

            -- Generate Unique Username & Email
            SET unique_username = CONCAT('User_', person_id);
            SET unique_email = CONCAT('user', person_id, '@email.com');

            -- Insert into User Profile
            UPDATE Person 
            SET Username = unique_username, 
                Password = CONCAT('Pass_', i), 
                Email = unique_email, 
                Phone_Number = phone_number, 
                Age_Restriction = age_restriction, 
                FK_Subscription = subscription_id
            WHERE ID_Person = person_id;
        END IF;

        SET i = i + 1;
    END WHILE;
    COMMIT;
END //

DELIMITER ;



-- Klic procedur za vstavljanje podatkov
CALL InsertProductionStudios(1000);
CALL InsertGenres();
CALL InsertMovies(1000);
CALL InsertMovieGenres(1000);
CALL InsertReviews(1000);
CALL InsertAwards(1000);
CALL InsertMovieAwards(1000);
CALL InsertSubscriptions(1000);
SET SQL_SAFE_UPDATES = 0;
CALL UpdateMovieRatings();
SET SQL_SAFE_UPDATES = 1;
CALL InsertPeople(1000);
