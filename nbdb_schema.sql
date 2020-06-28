-- --------------------------------------------------------
-- Host:                         nbdb2.cfhzccqz8ky4.us-east-2.rds.amazonaws.com
-- Server version:               5.7.30-log - Source distribution
-- Server OS:                    Linux
-- HeidiSQL Version:             11.0.0.5919
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Dumping database structure for NBDB
CREATE DATABASE IF NOT EXISTS `NBDB` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `NBDB`;

-- Dumping structure for function NBDB.Call2HexStr
DELIMITER //
CREATE FUNCTION `Call2HexStr`( `TStamp` BIGINT, `Num` VARCHAR(18) ) RETURNS char(54) CHARSET latin1
    NO SQL
    SQL SECURITY INVOKER
BEGIN

    RETURN CONCAT( LPAD( HEX( `TStamp` ), 16, 0 )
                 , LPAD( HEX( CHAR_LENGTH( `Num` ) ), 2, 0 )
                 , RPAD( HEX( `Num` ), 36, 0 ) );

END//
DELIMITER ;

-- Dumping structure for function NBDB.CurrentTimestampUTC
DELIMITER //
CREATE FUNCTION `CurrentTimestampUTC`() RETURNS timestamp(6)
    NO SQL
    SQL SECURITY INVOKER
BEGIN

    RETURN `SessionTimestamp2UTC`( CURRENT_TIMESTAMP( 6 ) );

END//
DELIMITER ;

-- Dumping structure for procedure NBDB.DecodeCall
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

-- Dumping structure for table NBDB.ExtAccount
CREATE TABLE IF NOT EXISTS `ExtAccount` (
  `Number` varchar(18) NOT NULL,
  `NetOp_ID` int(10) unsigned NOT NULL,
  `ExtServer_Number` varchar(18) NOT NULL,
  `Password` varchar(32) DEFAULT NULL,
  `CreationTStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `InUseStartTStamp` timestamp(6) NULL DEFAULT NULL,
  PRIMARY KEY (`Number`),
  KEY `ExtAccount_CreationTStamp` (`CreationTStamp`),
  KEY `ExtAccount_InUseStartTStamp` (`InUseStartTStamp`),
  KEY `FK_ExtAccount_NetOp_ID` (`NetOp_ID`),
  KEY `FK_ExtAccount_ExtServer_Number` (`ExtServer_Number`),
  CONSTRAINT `FK_ExtAccount_ExtServer_Number` FOREIGN KEY (`ExtServer_Number`) REFERENCES `ExtServer` (`Number`),
  CONSTRAINT `FK_ExtAccount_NetOp_ID` FOREIGN KEY (`NetOp_ID`) REFERENCES `NetOp` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;

-- Data exporting was unselected.

-- Dumping structure for table NBDB.ExtServer
CREATE TABLE IF NOT EXISTS `ExtServer` (
  `Number` varchar(18) NOT NULL,
  `NetOp_ID` int(10) unsigned NOT NULL,
  `Pattern` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`Number`),
  KEY `FK_ExtServer_NetOp_ID` (`NetOp_ID`),
  CONSTRAINT `FK_ExtServer_NetOp_ID` FOREIGN KEY (`NetOp_ID`) REFERENCES `NetOp` (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;

-- Data exporting was unselected.

-- Dumping structure for function NBDB.IsPreviousMonth
DELIMITER //
CREATE FUNCTION `IsPreviousMonth`( `DateVal` DATE ) RETURNS tinyint(1)
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

-- Dumping structure for function NBDB.IsPreviousTStamp
DELIMITER //
CREATE FUNCTION `IsPreviousTStamp`( `TStamp` TIMESTAMP ) RETURNS tinyint(1)
    NO SQL
    SQL SECURITY INVOKER
    COMMENT 'Returns a BOOLEAN value indicating whether or not the passed UTC TIMESTAMP value represents a time in the past compared with the current time.'
BEGIN

    RETURN ISNULL( TStamp ) OR (TStamp < CurrentTimestampUTC());

END//
DELIMITER ;

-- Dumping structure for function NBDB.IsUTCTStampNil
DELIMITER //
CREATE FUNCTION `IsUTCTStampNil`( `TStamp` TIMESTAMP ) RETURNS tinyint(4)
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

-- Dumping structure for table NBDB.NetOp
CREATE TABLE IF NOT EXISTS `NetOp` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Name` varchar(32) NOT NULL,
  `MaxExtAccountInUseSeconds` bigint(20) unsigned DEFAULT '120',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;

-- Data exporting was unselected.

-- Dumping structure for function NBDB.SessionTimestamp2UTC
DELIMITER //
CREATE FUNCTION `SessionTimestamp2UTC`( `TStamp` TIMESTAMP(6) ) RETURNS timestamp(6)
    NO SQL
    SQL SECURITY INVOKER
BEGIN

    RETURN CONVERT_TZ( `TStamp`, @@session.time_zone, '+00:00' );

END//
DELIMITER ;

-- Dumping structure for procedure NBDB.ValidateExtNum
DELIMITER //
CREATE PROCEDURE `ValidateExtNum`( IN ExtNum VARCHAR(18) )
BEGIN

    IF (ExtNum IS NOT NULL) AND (ExtNum NOT REGEXP '^1?[0-9]{10}$') THEN
        SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Invalid `ExtNum` column value';
    END IF;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
