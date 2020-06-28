SET @OLD_CHARACTER_SET_CLIENT = @@CHARACTER_SET_CLIENT;
SET NAMES utf8;
SET NAMES utf8mb4;
SET @OLD_FOREIGN_KEY_CHECKS = @@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS = 0;
SET @OLD_SQL_MODE = @@SQL_MODE, SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';


CREATE USER IF NOT EXISTS 'NBApp_Mgr'@'localhost' IDENTIFIED BY 'NBApp_Mgr_1234';
CREATE USER IF NOT EXISTS 'NBApp_Mgr'@'%'         IDENTIFIED BY 'NBApp_Mgr_1234';
CREATE USER IF NOT EXISTS 'NBApp_CP'@'localhost'  IDENTIFIED BY 'NBApp_CP_1234';
CREATE USER IF NOT EXISTS 'NBApp_CP'@'%'          IDENTIFIED BY 'NBApp_CP_1234';
CREATE USER IF NOT EXISTS 'NBApp_API'@'localhost' IDENTIFIED BY 'NBApp_API_1234';
CREATE USER IF NOT EXISTS 'NBApp_API'@'%'         IDENTIFIED BY 'NBApp_API_1234';


CREATE DATABASE IF NOT EXISTS `NBDB`;


USE `NBDB`;


DROP FUNCTION IF EXISTS `SessionTimestamp2UTC`;
DELIMITER //
CREATE FUNCTION `SessionTimestamp2UTC`( `TStamp` TIMESTAMP(6) ) RETURNS TIMESTAMP(6)
    NO SQL
    SQL SECURITY INVOKER
BEGIN

    RETURN CONVERT_TZ( `TStamp`, @@session.time_zone, '+00:00' );

END//
DELIMITER ;

GRANT EXECUTE, ALTER ROUTINE ON FUNCTION `SessionTimestamp2UTC` TO 'NBApp_Mgr'@'%'         WITH GRANT OPTION;
GRANT EXECUTE, ALTER ROUTINE ON FUNCTION `SessionTimestamp2UTC` TO 'NBApp_Mgr'@'localhost' WITH GRANT OPTION;
GRANT EXECUTE                ON FUNCTION `SessionTimestamp2UTC` TO 'NBApp_CP'@'%';
GRANT EXECUTE                ON FUNCTION `SessionTimestamp2UTC` TO 'NBApp_CP'@'localhost';
GRANT EXECUTE                ON FUNCTION `SessionTimestamp2UTC` TO 'NBApp_API'@'%';
GRANT EXECUTE                ON FUNCTION `SessionTimestamp2UTC` TO 'NBApp_API'@'localhost';


DROP FUNCTION IF EXISTS `CurrentTimestampUTC`;
DELIMITER //
CREATE FUNCTION `CurrentTimestampUTC`() RETURNS TIMESTAMP(6)
    NO SQL
    SQL SECURITY INVOKER
BEGIN

    RETURN `SessionTimestamp2UTC`( CURRENT_TIMESTAMP( 6 ) );

END//
DELIMITER ;

GRANT EXECUTE, ALTER ROUTINE ON FUNCTION `CurrentTimestampUTC` TO 'NBApp_Mgr'@'%'         WITH GRANT OPTION;
GRANT EXECUTE, ALTER ROUTINE ON FUNCTION `CurrentTimestampUTC` TO 'NBApp_Mgr'@'localhost' WITH GRANT OPTION;
GRANT EXECUTE                ON FUNCTION `CurrentTimestampUTC` TO 'NBApp_CP'@'%';
GRANT EXECUTE                ON FUNCTION `CurrentTimestampUTC` TO 'NBApp_CP'@'localhost';
GRANT EXECUTE                ON FUNCTION `CurrentTimestampUTC` TO 'NBApp_API'@'%';
GRANT EXECUTE                ON FUNCTION `CurrentTimestampUTC` TO 'NBApp_API'@'localhost';


DROP FUNCTION IF EXISTS `IsUTCTStampNil`;
DELIMITER //
CREATE FUNCTION `IsUTCTStampNil`( `TStamp` TIMESTAMP ) RETURNS TINYINT
    NO SQL
    DETERMINISTIC
    SQL SECURITY INVOKER
BEGIN

    IF ( ISNULL( TStamp ) OR (YEAR( CONVERT_TZ( TStamp, @@session.time_zone, '+00:00' ) ) = 0) ) THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;

END//
DELIMITER ;

GRANT EXECUTE, ALTER ROUTINE ON FUNCTION `IsUTCTStampNil` TO 'NBApp_Mgr'@'%'         WITH GRANT OPTION;
GRANT EXECUTE, ALTER ROUTINE ON FUNCTION `IsUTCTStampNil` TO 'NBApp_Mgr'@'localhost' WITH GRANT OPTION;
GRANT EXECUTE                ON FUNCTION `IsUTCTStampNil` TO 'NBApp_CP'@'%';
GRANT EXECUTE                ON FUNCTION `IsUTCTStampNil` TO 'NBApp_CP'@'localhost';
GRANT EXECUTE                ON FUNCTION `IsUTCTStampNil` TO 'NBApp_API'@'%';
GRANT EXECUTE                ON FUNCTION `IsUTCTStampNil` TO 'NBApp_API'@'localhost';



DROP FUNCTION IF EXISTS `IsPreviousMonth`;
DELIMITER //
CREATE FUNCTION `IsPreviousMonth`( `DateVal` DATE ) RETURNS BOOLEAN
    NO SQL
    SQL SECURITY INVOKER
    COMMENT 'Returns a BOOLEAN value indicating whether or not the passed UTC DATE value represents a month prior to the current month.'
BEGIN

    DECLARE CurrDate     DATE;
    DECLARE CurrMonthVal INTEGER UNSIGNED;
    DECLARE ArgMonthVal  INTEGER UNSIGNED;

    IF ( ISNULL( DateVal ) ) THEN
        RETURN TRUE;
    END IF;

    SET CurrDate     = DATE( CONVERT_TZ( NOW( 6 ), @@session.time_zone, '+00:00' ) );
    SET CurrMonthVal = ((YEAR( CurrDate ) * 12) + MONTH( CurrDate ));
    SET ArgMonthVal  = ((YEAR( DateVal  ) * 12) + MONTH( DateVal  ));

    RETURN ArgMonthVal < CurrMonthVal;

END//
DELIMITER ;

GRANT EXECUTE, ALTER ROUTINE ON FUNCTION `IsPreviousMonth` TO 'NBApp_Mgr'@'%'         WITH GRANT OPTION;
GRANT EXECUTE, ALTER ROUTINE ON FUNCTION `IsPreviousMonth` TO 'NBApp_Mgr'@'localhost' WITH GRANT OPTION;
GRANT EXECUTE                ON FUNCTION `IsPreviousMonth` TO 'NBApp_CP'@'%';
GRANT EXECUTE                ON FUNCTION `IsPreviousMonth` TO 'NBApp_CP'@'localhost';
GRANT EXECUTE                ON FUNCTION `IsPreviousMonth` TO 'NBApp_API'@'%';
GRANT EXECUTE                ON FUNCTION `IsPreviousMonth` TO 'NBApp_API'@'localhost';


DROP FUNCTION IF EXISTS `IsPreviousTStamp`;
DELIMITER //
CREATE FUNCTION `IsPreviousTStamp`( `TStamp` TIMESTAMP ) RETURNS BOOLEAN
    NO SQL
    SQL SECURITY INVOKER
    COMMENT 'Returns a BOOLEAN value indicating whether or not the passed UTC TIMESTAMP value represents a time in the past compared with the current time.'
BEGIN

    RETURN ISNULL( TStamp ) OR (TStamp < CurrentTimestampUTC());

END//
DELIMITER ;

GRANT EXECUTE, ALTER ROUTINE ON FUNCTION `IsPreviousTStamp` TO 'NBApp_Mgr'@'%'         WITH GRANT OPTION;
GRANT EXECUTE, ALTER ROUTINE ON FUNCTION `IsPreviousTStamp` TO 'NBApp_Mgr'@'localhost' WITH GRANT OPTION;
GRANT EXECUTE                ON FUNCTION `IsPreviousTStamp` TO 'NBApp_CP'@'%';
GRANT EXECUTE                ON FUNCTION `IsPreviousTStamp` TO 'NBApp_CP'@'localhost';
GRANT EXECUTE                ON FUNCTION `IsPreviousTStamp` TO 'NBApp_API'@'%';
GRANT EXECUTE                ON FUNCTION `IsPreviousTStamp` TO 'NBApp_API'@'localhost';


DROP FUNCTION IF EXISTS `Call2HexStr`;
DELIMITER //
CREATE FUNCTION `Call2HexStr`( `TStamp` BIGINT, `Num` VARCHAR(18) ) RETURNS CHAR(54)
    NO SQL
    SQL SECURITY INVOKER
BEGIN

    RETURN CONCAT( LPAD( HEX( `TStamp` ), 16, 0 )
                 , LPAD( HEX( CHAR_LENGTH( `Num` ) ), 2, 0 )
                 , RPAD( HEX( `Num` ), 36, 0 ) );

END//
DELIMITER ;

GRANT EXECUTE, ALTER ROUTINE ON FUNCTION `Call2HexStr` TO 'NBApp_Mgr'@'%'         WITH GRANT OPTION;
GRANT EXECUTE, ALTER ROUTINE ON FUNCTION `Call2HexStr` TO 'NBApp_Mgr'@'localhost' WITH GRANT OPTION;
GRANT EXECUTE                ON FUNCTION `Call2HexStr` TO 'NBApp_CP'@'%';
GRANT EXECUTE                ON FUNCTION `Call2HexStr` TO 'NBApp_CP'@'localhost';
GRANT EXECUTE                ON FUNCTION `Call2HexStr` TO 'NBApp_API'@'%';
GRANT EXECUTE                ON FUNCTION `Call2HexStr` TO 'NBApp_API'@'localhost';




DROP PROCEDURE IF EXISTS `DecodeCall`;
DELIMITER //
CREATE PROCEDURE `DecodeCall`( IN  `Calls` VARBINARY(5600)
                                   , IN  `Idx`         INT
                                   , OUT `TStamp`      BIGINT
                                   , OUT `NumLen`     TINYINT
                                   , OUT `Num`        VARCHAR(18)
                                   , OUT `Result`      TINYINT )
BEGIN

    DECLARE Pos INT;

    SET Pos = ((Idx * 27) + 1);
    IF ( (Idx < 0) || ((Pos + 27) > (LENGTH( Calls ) + 1)) ) THEN
        SET Result = 0;
    ELSE
        SET TStamp    = CONV( HEX( MID( Calls, Pos, 8 ) ), 16, 10 );
        SET NumLen   = CONV( HEX( MID( Calls, Pos + 8, 1 ) ), 16, 10 );
        SET Num      = MID( Calls, Pos + 9, NumLen );
        SET Result    = 1;
    END IF;

END//
DELIMITER ;

GRANT EXECUTE, ALTER ROUTINE ON PROCEDURE `DecodeCall` TO 'NBApp_Mgr'@'%'         WITH GRANT OPTION;
GRANT EXECUTE, ALTER ROUTINE ON PROCEDURE `DecodeCall` TO 'NBApp_Mgr'@'localhost' WITH GRANT OPTION;
GRANT EXECUTE                ON PROCEDURE `DecodeCall` TO 'NBApp_CP'@'%';
GRANT EXECUTE                ON PROCEDURE `DecodeCall` TO 'NBApp_CP'@'localhost';
GRANT EXECUTE                ON PROCEDURE `DecodeCall` TO 'NBApp_API'@'%';
GRANT EXECUTE                ON PROCEDURE `DecodeCall` TO 'NBApp_API'@'localhost';


DROP PROCEDURE IF EXISTS `ValidateExtNum`;
DELIMITER //
CREATE PROCEDURE `ValidateExtNum`( IN ExtNum VARCHAR(18) )
BEGIN

    IF (ExtNum IS NOT NULL) AND (ExtNum NOT REGEXP '^1?[0-9]{10}$') THEN
        SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Invalid `ExtNum` column value';
    END IF;

END//
DELIMITER ;

GRANT EXECUTE, ALTER ROUTINE ON PROCEDURE `ValidateExtNum` TO 'NBApp_Mgr'@'%'         WITH GRANT OPTION;
GRANT EXECUTE, ALTER ROUTINE ON PROCEDURE `ValidateExtNum` TO 'NBApp_Mgr'@'localhost' WITH GRANT OPTION;
GRANT EXECUTE                ON PROCEDURE `ValidateExtNum` TO 'NBApp_CP'@'%';
GRANT EXECUTE                ON PROCEDURE `ValidateExtNum` TO 'NBApp_CP'@'localhost';
GRANT EXECUTE                ON PROCEDURE `ValidateExtNum` TO 'NBApp_API'@'%';
GRANT EXECUTE                ON PROCEDURE `ValidateExtNum` TO 'NBApp_API'@'localhost';




CREATE TABLE IF NOT EXISTS `NetOp` (
  `ID`                              INTEGER UNSIGNED     NOT NULL AUTO_INCREMENT,
  `Name`                            VARCHAR(32)          NOT NULL,
  `MaxExtAccountInUseSeconds`        BIGINT UNSIGNED          NULL DEFAULT 120,
  PRIMARY KEY (`ID`)
) ENGINE          = InnoDB
  ROW_FORMAT      = DYNAMIC
  DEFAULT CHARSET = latin1;

GRANT                 SELECT         ON TABLE `NetOp` TO 'NBApp_CP'@'%';
GRANT                 SELECT         ON TABLE `NetOp` TO 'NBApp_CP'@'localhost';
GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE `NetOp` TO 'NBApp_API'@'%';
GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE `NetOp` TO 'NBApp_API'@'localhost';


CREATE TABLE IF NOT EXISTS `ExtServer` (
  `Number`                          VARCHAR(18)          NOT NULL,
  `NetOp_ID`                  INTEGER UNSIGNED     NOT NULL,
  `Pattern`                     VARCHAR(200)             NULL DEFAULT NULL,
  PRIMARY KEY (`Number`),
  CONSTRAINT `FK_ExtServer_NetOp_ID` FOREIGN KEY (`NetOp_ID`) REFERENCES `NetOp` (`ID`)
) ENGINE          = InnoDB
  ROW_FORMAT      = DYNAMIC
  DEFAULT CHARSET = latin1;

GRANT                 SELECT         ON TABLE `ExtServer` TO 'NBApp_CP'@'%';
GRANT                 SELECT         ON TABLE `ExtServer` TO 'NBApp_CP'@'localhost';
GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE `ExtServer` TO 'NBApp_API'@'%';
GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE `ExtServer` TO 'NBApp_API'@'localhost';


CREATE TABLE IF NOT EXISTS `ExtAccount` (
  `Number`                          VARCHAR(18)          NOT NULL,
  `NetOp_ID`                  INTEGER UNSIGNED     NOT NULL,
  `ExtServer_Number`                 VARCHAR(18)          NOT NULL,
  `Password`                        VARCHAR(32)              NULL DEFAULT NULL,
  `CreationTStamp`                  TIMESTAMP(0)         NOT NULL DEFAULT CURRENT_TIMESTAMP(), 
  `InUseStartTStamp`                TIMESTAMP(6)             NULL DEFAULT NULL,
  PRIMARY KEY                      (`Number`),
  KEY `ExtAccount_CreationTStamp`   (`CreationTStamp`),
  KEY `ExtAccount_InUseStartTStamp` (`InUseStartTStamp`),
  CONSTRAINT `FK_ExtAccount_NetOp_ID`  FOREIGN KEY (`NetOp_ID`)  REFERENCES `NetOp` (`ID`),
  CONSTRAINT `FK_ExtAccount_ExtServer_Number` FOREIGN KEY (`ExtServer_Number`) REFERENCES `ExtServer` (`Number`)
) ENGINE          = InnoDB
  ROW_FORMAT      = DYNAMIC
  DEFAULT CHARSET = latin1;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE `ExtAccount` TO 'NBApp_CP'@'%';
GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE `ExtAccount` TO 'NBApp_CP'@'localhost';
GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE `ExtAccount` TO 'NBApp_API'@'%';
GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE `ExtAccount` TO 'NBApp_API'@'localhost';


SET SQL_MODE             = IFNULL( @OLD_SQL_MODE, '' );
SET FOREIGN_KEY_CHECKS   = IF( @OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS );
SET CHARACTER_SET_CLIENT = @OLD_CHARACTER_SET_CLIENT;



