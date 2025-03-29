-- MySQL Workbench Forward Engineering
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema datawarehouse
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `datawarehouse` DEFAULT CHARACTER SET utf8mb3 ;
USE `datawarehouse` ;

CREATE USER IF NOT EXISTS 'datawarehouse'@'localhost' IDENTIFIED BY 'datawarehouse';
GRANT ALL PRIVILEGES ON datawarehouse.* TO 'datawarehouse'@'localhost';

DROP TABLE IF EXISTS `datawarehouse`.`Movie`;
DROP TABLE IF EXISTS `datawarehouse`.`Genre`;
DROP TABLE IF EXISTS `datawarehouse`.`DateAndTime`;
DROP TABLE IF EXISTS `datawarehouse`.`Production_Studio`;
DROP TABLE IF EXISTS `datawarehouse`.`Director`;
DROP TABLE IF EXISTS `datawarehouse`.`Movie_Performance`;
DROP PROCEDURE IF EXISTS populate_dateandtime;

-- -----------------------------------------------------
-- Table `datawarehouse`.`Movie`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `datawarehouse`.`Movie` (
  `idMovie` INT NOT NULL AUTO_INCREMENT,
  `Title` VARCHAR(255) NOT NULL,
  `Release_Year` YEAR NOT NULL,
  `Release_Date` DATE NULL,
  `Length` TIME NULL,
  `Movie_Description` TEXT NULL,
  `Rating` INT NULL,
  PRIMARY KEY (`idMovie`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `datawarehouse`.`Genre`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `datawarehouse`.`Genre` (
  `idGenre` INT NOT NULL AUTO_INCREMENT,
  `Genre` ENUM("Action", "Fantasy", "Sci-Fi", "Romance", "Drama", "Horror", "Thriller", "Mistery", "Crime") NOT NULL,
  PRIMARY KEY (`idGenre`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `datawarehouse`.`DateAndTime`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `datawarehouse`.`DateAndTime` (
  `idDateAndTime` INT NOT NULL AUTO_INCREMENT,
  `Date` DATE NULL,
  `Year` YEAR NULL,
  `Month` INT NULL,
  `Week` INT NULL,
  `Day` INT NULL,
  `MonthString` ENUM("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December") NULL,
  `DayString` ENUM("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday") NULL,
  `MonthInYear` INT NULL,
  `WeekInMonth` INT NULL,
  `WeekInYear` INT NULL,
  `DayInYear` INT NULL,
  `DayInMonth` INT NULL,
  `DayInWeek` INT NULL,
  PRIMARY KEY (`idDateAndTime`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `datawarehouse`.`Production_Studio`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `datawarehouse`.`Production_Studio` (
  `idProduction_Studio` INT NOT NULL AUTO_INCREMENT,
  `Studio_Name` VARCHAR(255) NOT NULL,
  `Studio_Type` ENUM("Standalone", "Subsidiary", "Production", "Publishing", "Streaming", "Major", "Independant") NOT NULL,
  `Year_Established` YEAR NOT NULL,
  `Budget` INT NULL,
  PRIMARY KEY (`idProduction_Studio`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `datawarehouse`.`Director`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `datawarehouse`.`Director` (
  `idDirector` INT NOT NULL AUTO_INCREMENT,
  `Full_Name` VARCHAR(255) NOT NULL,
  `Directing_Status` VARCHAR(45) NOT NULL,
  `Date_Of_Birth` DATE NULL,
  `Place_Of_Birth` VARCHAR(45) NULL,
  `Gender` ENUM("Male", "Female") NULL,
  PRIMARY KEY (`idDirector`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `datawarehouse`.`Movie_Performance`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `datawarehouse`.`Movie_Performance` (
  `FK_Production_Studio` INT NULL,
  `FK_Movie` INT NULL,
  `FK_Genre` INT NULL,
  `FK_Director` INT NULL,
  `FK_DateAndTime` INT NULL,
  `TotalViews` INT NULL,
  `AverageReviewScore` INT NULL,
  `TotalAwardsWon` INT NULL,
  `TotalReviewCount` INT NULL,
  `TotalMovieLengthMinutes` INT NULL,
  INDEX `fk_Movie_Performance_Movie1_idx` (`FK_Movie` ASC) VISIBLE,
  INDEX `fk_Movie_Performance_Genre1_idx` (`FK_Genre` ASC) VISIBLE,
  INDEX `fk_Movie_Performance_DateAndTime1_idx` (`FK_DateAndTime` ASC) VISIBLE,
  INDEX `fk_Movie_Performance_Production_Studio1_idx` (`FK_Production_Studio` ASC) VISIBLE,
  INDEX `fk_Movie_Performance_Director1_idx` (`FK_Director` ASC) VISIBLE,
  CONSTRAINT `fk_Movie_Performance_Movie1`
    FOREIGN KEY (`FK_Movie`)
    REFERENCES `datawarehouse`.`Movie` (`idMovie`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Movie_Performance_Genre1`
    FOREIGN KEY (`FK_Genre`)
    REFERENCES `datawarehouse`.`Genre` (`idGenre`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Movie_Performance_DateAndTime1`
    FOREIGN KEY (`FK_DateAndTime`)
    REFERENCES `datawarehouse`.`DateAndTime` (`idDateAndTime`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Movie_Performance_Production_Studio1`
    FOREIGN KEY (`FK_Production_Studio`)
    REFERENCES `datawarehouse`.`Production_Studio` (`idProduction_Studio`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Movie_Performance_Director1`
    FOREIGN KEY (`FK_Director`)
    REFERENCES `datawarehouse`.`Director` (`idDirector`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

DELIMITER $$
CREATE PROCEDURE populate_dateandtime()
BEGIN
    DECLARE v_current_date DATE;
    DECLARE v_end_date DATE;
    DECLARE v_day_of_week INT;
    DECLARE v_week_of_month INT;

    SET v_current_date = CURDATE() - INTERVAL 4 YEAR;
    SET v_end_date = CURDATE();

    WHILE v_current_date <= v_end_date DO
        SET v_day_of_week = WEEKDAY(v_current_date) + 1;
        SET v_week_of_month = WEEK(v_current_date, 1) -
            WEEK(DATE_SUB(v_current_date, INTERVAL DAY(v_current_date) - 1 DAY), 1) + 1;

        IF NOT EXISTS (
            SELECT 1 FROM DateAndTime WHERE `Date` = v_current_date
        ) THEN
            INSERT INTO DateAndTime (
                `Date`,
                `Year`,
                `Month`,
                `Week`,
                `Day`,
                `MonthString`,
                `DayString`,
                `MonthInYear`,
                `WeekInMonth`,
                `WeekInYear`,
                `DayInYear`,
                `DayInMonth`,
                `DayInWeek`
            ) VALUES (
                v_current_date,
                YEAR(v_current_date),
                MONTH(v_current_date),
                WEEK(v_current_date, 1),
                DAY(v_current_date),
                ELT(MONTH(v_current_date),
                    'January','February','March','April','May','June','July','August','September','October','November','December'),
                DAYNAME(v_current_date),
                MONTH(v_current_date),
                v_week_of_month,
                WEEK(v_current_date, 1),
                DAYOFYEAR(v_current_date),
                DAY(v_current_date),
                v_day_of_week
            );
        END IF;
        SET v_current_date = DATE_ADD(v_current_date, INTERVAL 1 DAY);
    END WHILE;
END$$
DELIMITER ;

CALL populate_dateandtime();

SELECT * FROM DateAndTime ORDER BY `Date` DESC LIMIT 30;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
