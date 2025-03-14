-- MySQL Workbench Forward Engineering
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `mydb` ;

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`Genre`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Genre` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Genre` (
  `ID_Genre` INT NOT NULL AUTO_INCREMENT,
  `Genre` ENUM("Action", "Fantasy", "Sci-Fi", "Romance", "Drama", "Horror", "Thriller", "Mistery", "Crime") NOT NULL,
  PRIMARY KEY (`ID_Genre`),
  UNIQUE INDEX `ID_Genre_UNIQUE` (`ID_Genre` ASC) VISIBLE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `mydb`.`Production_Studio`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Production_Studio` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Production_Studio` (
  `ID_Production_Studio` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `Studio_Name` VARCHAR(255) NOT NULL,
  `Studio_Type` ENUM("Standalone", "Subsidiary", "Production", "Publishing", "Streaming", "Major", "Independant") NOT NULL,
  `Year_Established` YEAR NOT NULL,
  `Budget` INT NULL,
  PRIMARY KEY (`ID_Production_Studio`),
  UNIQUE INDEX `ID_Production_Studio_UNIQUE` (`ID_Production_Studio` ASC) VISIBLE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `mydb`.`Movie`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Movie` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Movie` (
  `ID_Movie` INT NOT NULL AUTO_INCREMENT,
  `Title` VARCHAR(255) NOT NULL,
  `Release_Year` YEAR NOT NULL,
  `Release_Date` DATE NULL,
  `Length` TIME NULL DEFAULT 0,
  `Movie_Description` TEXT NULL,
  `Rating` INT NULL DEFAULT 0,
  `FK_Production_Studio` INT UNSIGNED NULL,
  PRIMARY KEY (`ID_Movie`),
  UNIQUE INDEX `ID_Movie_UNIQUE` (`ID_Movie` ASC) VISIBLE,
  INDEX `fk_Movie_Production_Studio_idx` (`FK_Production_Studio` ASC) VISIBLE,
  CONSTRAINT `fk_Movie_Production_Studio`
    FOREIGN KEY (`FK_Production_Studio`)
    REFERENCES `mydb`.`Production_Studio` (`ID_Production_Studio`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `mydb`.`Subscription`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Subscription` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Subscription` (
  `ID_Subscription` INT NOT NULL AUTO_INCREMENT,
  `Monthly_Price` FLOAT UNSIGNED NOT NULL,
  `Subscription_Price` FLOAT UNSIGNED NOT NULL,
  `Subscription_Type` ENUM("Standard", "Family", "Premium") NOT NULL,
  `Subscription_Description` VARCHAR(255) NOT NULL,
  `Start_Date` DATE NOT NULL,
  `Expiry_Date` DATE NOT NULL,
  PRIMARY KEY (`ID_Subscription`),
  UNIQUE INDEX `ID_Subscription_UNIQUE` (`ID_Subscription` ASC) VISIBLE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `mydb`.`Person`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Person` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Person` (
  `ID_Person` INT NOT NULL AUTO_INCREMENT,
  `First_Name` VARCHAR(45) NOT NULL,
  `Last_Name` VARCHAR(45) NOT NULL,
  `Date_Of_Birth` DATE NULL,
  `Place_Of_Birth` VARCHAR(45) NULL,
  `Gender` ENUM("Male", "Female") NULL,
  PRIMARY KEY (`ID_Person`),
  UNIQUE INDEX `ID_Person_UNIQUE` (`ID_Person` ASC) VISIBLE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `mydb`.`User_Profile`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`User_Profile`;

CREATE TABLE IF NOT EXISTS `mydb`.`User_Profile` (
  `ID_User_Profile` INT NOT NULL AUTO_INCREMENT,
  `Username` VARCHAR(100) NOT NULL,
  `Password` VARCHAR(100) NOT NULL,
  `Email` VARCHAR(100) NOT NULL,
  `Phone_Number` VARCHAR(30) NULL,
  `Age_Restriction` ENUM("Kids", "Underaged", "Adult") NOT NULL DEFAULT 'Underaged',
  `FK_Subscription` INT NULL,
  `FK_Person` INT NOT NULL,
  PRIMARY KEY (`ID_User_Profile`),
  INDEX `fk_User_Subscription_idx` (`FK_Subscription` ASC) VISIBLE,
  INDEX `fk_User_Person_idx` (`FK_Person` ASC) VISIBLE,
  UNIQUE INDEX `Email_UNIQUE` (`Email` ASC) VISIBLE,
  UNIQUE INDEX `FK_Person_UNIQUE` (`FK_Person` ASC) VISIBLE,
  UNIQUE INDEX `Username_UNIQUE` (`Username` ASC) VISIBLE,
  UNIQUE INDEX `ID_User_Profile_UNIQUE` (`ID_User_Profile` ASC) VISIBLE,
  CONSTRAINT `fk_User_Subscription`
    FOREIGN KEY (`FK_Subscription`)
    REFERENCES `mydb`.`Subscription` (`ID_Subscription`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_User_Person`
    FOREIGN KEY (`FK_Person`)
    REFERENCES `mydb`.`Person` (`ID_Person`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `mydb`.`Actor`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Actor` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Actor` (
  `ID_Actor` INT NOT NULL AUTO_INCREMENT,
  `Stage_Name` VARCHAR(45) NULL,
  `Acting_Status` ENUM("Active", "Retired", "Deceased") NULL,
  `FK_Person` INT NOT NULL,
  PRIMARY KEY (`ID_Actor`),
  INDEX `fk_Actor_Person_idx` (`FK_Person` ASC) VISIBLE,
  UNIQUE INDEX `FK_Person_UNIQUE` (`FK_Person` ASC) VISIBLE,
  UNIQUE INDEX `ID_Actor_UNIQUE` (`ID_Actor` ASC) VISIBLE,
  CONSTRAINT `fk_Actor_Person`
    FOREIGN KEY (`FK_Person`)
    REFERENCES `mydb`.`Person` (`ID_Person`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `mydb`.`Review`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Review` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Review` (
  `ID_Review` INT NOT NULL AUTO_INCREMENT,
  `Score` INT UNSIGNED NOT NULL,
  `Comment` VARCHAR(255) NULL,
  `FK_Movie` INT NOT NULL,
  PRIMARY KEY (`ID_Review`),
  INDEX `fk_Rating_Movie_idx` (`FK_Movie` ASC) VISIBLE,
  CONSTRAINT `fk_Rating_Movie`
    FOREIGN KEY (`FK_Movie`)
    REFERENCES `mydb`.`Movie` (`ID_Movie`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `mydb`.`Award`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Award` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Award` (
  `ID_Award` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `Award_Category` VARCHAR(255) NOT NULL,
  `Award_Type` ENUM("Oscar", "Golden Globe", "Movie Rewards") NOT NULL,
  PRIMARY KEY (`ID_Award`),
  UNIQUE INDEX `ID_Award_UNIQUE` (`ID_Award` ASC) VISIBLE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `mydb`.`Director`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Director` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Director` (
  `ID_Director` INT NOT NULL AUTO_INCREMENT,
  `Directing_Status` ENUM("Active", "Retired", "Deceased") NOT NULL,
  `FK_Person` INT NOT NULL,
  PRIMARY KEY (`ID_Director`),
  INDEX `fk_Director_Person_idx` (`FK_Person` ASC) VISIBLE,
  UNIQUE INDEX `ID_Director_UNIQUE` (`ID_Director` ASC) VISIBLE,
  CONSTRAINT `fk_Director_Person`
    FOREIGN KEY (`FK_Person`)
    REFERENCES `mydb`.`Person` (`ID_Person`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `mydb`.`Movie_Genre`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Movie_Genre` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Movie_Genre` (
  `ID_Movie_Genre` INT NOT NULL AUTO_INCREMENT,
  `FK_Movie` INT NOT NULL,
  `FK_Genre` INT NOT NULL,
  INDEX `fk_Movie_has_Genre_Genre_idx` (`FK_Genre` ASC) VISIBLE,
  INDEX `fk_Movie_has_Genre_Movie_idx` (`FK_Movie` ASC) VISIBLE,
  PRIMARY KEY (`ID_Movie_Genre`),
  UNIQUE INDEX `ID_Movie_Genre_UNIQUE` (`ID_Movie_Genre` ASC) VISIBLE,
  CONSTRAINT `fk_Movie_has_Genre_Movie`
    FOREIGN KEY (`FK_Movie`)
    REFERENCES `mydb`.`Movie` (`ID_Movie`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Movie_has_Genre_Genre`
    FOREIGN KEY (`FK_Genre`)
    REFERENCES `mydb`.`Genre` (`ID_Genre`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `mydb`.`Actor_Movie`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Actor_Movie` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Actor_Movie` (
  `ID_Actor_Movie` INT NOT NULL AUTO_INCREMENT,
  `FK_Actor` INT NOT NULL,
  `FK_Movie` INT NOT NULL,
  INDEX `fk_Actor_has_Movie_Movie_idx` (`FK_Movie` ASC) VISIBLE,
  INDEX `fk_Actor_has_Movie_Actor_idx` (`FK_Actor` ASC) VISIBLE,
  PRIMARY KEY (`ID_Actor_Movie`),
  UNIQUE INDEX `ID_Actor_Movie_UNIQUE` (`ID_Actor_Movie` ASC) VISIBLE,
  CONSTRAINT `fk_Actor_has_Movie_Actor`
    FOREIGN KEY (`FK_Actor`)
    REFERENCES `mydb`.`Actor` (`ID_Actor`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Actor_has_Movie_Movie`
    FOREIGN KEY (`FK_Movie`)
    REFERENCES `mydb`.`Movie` (`ID_Movie`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `mydb`.`Director_Movie`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Director_Movie` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Director_Movie` (
  `ID_Director_Movie` INT NOT NULL AUTO_INCREMENT,
  `FK_Movie` INT NOT NULL,
  `FK_Director` INT NOT NULL,
  INDEX `fk_Movie_has_Director_Director2_idx` (`FK_Director` ASC) VISIBLE,
  INDEX `fk_Movie_has_Director_Movie2_idx` (`FK_Movie` ASC) VISIBLE,
  PRIMARY KEY (`ID_Director_Movie`),
  UNIQUE INDEX `ID_Director_Movie_UNIQUE` (`ID_Director_Movie` ASC) VISIBLE,
  CONSTRAINT `fk_Movie_has_Director_Movie2`
    FOREIGN KEY (`FK_Movie`)
    REFERENCES `mydb`.`Movie` (`ID_Movie`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Movie_has_Director_Director2`
    FOREIGN KEY (`FK_Director`)
    REFERENCES `mydb`.`Director` (`ID_Director`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `mydb`.`Movie_Award`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`Movie_Award` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Movie_Award` (
  `ID_Movie_Award` INT NOT NULL AUTO_INCREMENT,
  `FK_Movie` INT NOT NULL,
  `FK_Award` INT UNSIGNED NOT NULL,
  INDEX `fk_Movie_has_Award_Award_idx` (`FK_Award` ASC) VISIBLE,
  INDEX `fk_Movie_has_Award_Movie_idx` (`FK_Movie` ASC) VISIBLE,
  PRIMARY KEY (`ID_Movie_Award`),
  UNIQUE INDEX `ID_Movie_Award_UNIQUE` (`ID_Movie_Award` ASC) VISIBLE,
  CONSTRAINT `fk_Movie_has_Award_Movie`
    FOREIGN KEY (`FK_Movie`)
    REFERENCES `mydb`.`Movie` (`ID_Movie`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Movie_has_Award_Award`
    FOREIGN KEY (`FK_Award`)
    REFERENCES `mydb`.`Award` (`ID_Award`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

USE `mydb`;
DELIMITER $$

USE `mydb`$$
DROP TRIGGER IF EXISTS `mydb`.`Movie_BEFORE_INSERT_RATING` $$
USE `mydb`$$
CREATE DEFINER = CURRENT_USER TRIGGER `mydb`.`Movie_BEFORE_INSERT_RATING` BEFORE INSERT ON `Movie` FOR EACH ROW
BEGIN
	IF NEW.Rating IS NULL THEN
        SET NEW.Rating = 0;
	END IF;
END$$

USE `mydb`$$
DROP TRIGGER IF EXISTS `mydb`.`Subscription_BEFORE_INSERT` $$
USE `mydb`$$
CREATE DEFINER = CURRENT_USER TRIGGER `mydb`.`Subscription_BEFORE_INSERT` BEFORE INSERT ON `Subscription` FOR EACH ROW
BEGIN
   IF NEW.Expiry_Date IS NULL THEN
        IF NEW.Subscription_Type = 'Monthly' THEN
            SET NEW.Expiry_Date = DATE_ADD(NEW.Start_Date, INTERVAL 1 MONTH);
        ELSEIF NEW.Subscription_Type = 'Yearly' THEN
            SET NEW.Expiry_Date = DATE_ADD(NEW.Start_Date, INTERVAL 1 YEAR);
        ELSE
            SET NEW.Expiry_Date = NEW.Start_Date; -- Default to same date if type is unknown
        END IF;
	END IF;
END$$

USE `mydb`$$
DROP TRIGGER IF EXISTS `mydb`.`Subscription_BEFORE_UPDATE_EXPIRY_DATE` $$
USE `mydb`$$
CREATE DEFINER = CURRENT_USER TRIGGER `mydb`.`Subscription_BEFORE_UPDATE_EXPIRY_DATE` BEFORE UPDATE ON `Subscription` FOR EACH ROW
BEGIN
    IF NEW.Expiry_Date < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Expiry date cannot be in the past.';
    END IF;
END$$

USE `mydb`$$
DROP TRIGGER IF EXISTS `mydb`.`User_Profile_BEFORE_INSERT_EXISTS` $$
USE `mydb`$$
CREATE DEFINER = CURRENT_USER TRIGGER `mydb`.`User_Profile_BEFORE_INSERT_EXISTS` BEFORE INSERT ON `User_Profile` FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM User_Profile WHERE Username = NEW.Username) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Username already exists';
    END IF;
END$$

USE `mydb`$$
DROP TRIGGER IF EXISTS `mydb`.`User_Profile_BEFORE_INSERT_AGE` $$
USE `mydb`$$
CREATE DEFINER = CURRENT_USER TRIGGER `mydb`.`User_Profile_BEFORE_INSERT_AGE` BEFORE INSERT ON `User_Profile` FOR EACH ROW
BEGIN
DECLARE user_age INT;
    SELECT TIMESTAMPDIFF(YEAR, (SELECT Date_Of_Birth FROM Person WHERE ID_Person = NEW.FK_Person), CURDATE()) INTO user_age;

    IF user_age < (
        CASE NEW.Age_Restriction
            WHEN '18+' THEN 18
            WHEN '16+' THEN 16
            WHEN '13+' THEN 13
            ELSE 0
        END
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User does not meet age restriction.';
    END IF;
END$$

USE `mydb`$$
DROP TRIGGER IF EXISTS `mydb`.`Actor_Movie_BEFORE_INSERT_SINGLE_ACTOR` $$
USE `mydb`$$
CREATE DEFINER = CURRENT_USER TRIGGER `mydb`.`Actor_Movie_BEFORE_INSERT_SINGLE_ACTOR` BEFORE INSERT ON `Actor_Movie` FOR EACH ROW
BEGIN
	IF EXISTS (SELECT 1 FROM Actor_Movie 
	   WHERE FK_Actor = NEW.FK_Actor 
	   AND FK_Movie = NEW.FK_Movie) 
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Actor is already assigned to this movie.';
    END IF;
END$$

DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;