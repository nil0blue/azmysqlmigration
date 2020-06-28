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

-- Dumping data for table NBDB.ExtAccount: ~0 rows (approximately)
/*!40000 ALTER TABLE `ExtAccount` DISABLE KEYS */;
INSERT INTO `ExtAccount` (`Number`, `NetOp_ID`, `ExtServer_Number`, `Password`, `CreationTStamp`, `InUseStartTStamp`) VALUES
	('1212', 1, '1', 'xxx', '2020-06-28 02:11:05', NULL),
	('3434', 1, '1', 'yyy', '2020-06-27 21:12:05', NULL),
	('5656', 2, '1', 'xxxxxxxxx', '2020-06-28 02:11:05', NULL);
/*!40000 ALTER TABLE `ExtAccount` ENABLE KEYS */;

-- Dumping data for table NBDB.ExtServer: ~0 rows (approximately)
/*!40000 ALTER TABLE `ExtServer` DISABLE KEYS */;
INSERT INTO `ExtServer` (`Number`, `NetOp_ID`, `Pattern`) VALUES
	('1', 1, '1111111'),
	('2', 1, '2222');
/*!40000 ALTER TABLE `ExtServer` ENABLE KEYS */;

-- Dumping data for table NBDB.NetOp: ~0 rows (approximately)
/*!40000 ALTER TABLE `NetOp` DISABLE KEYS */;
INSERT INTO `NetOp` (`ID`, `Name`, `MaxExtAccountInUseSeconds`) VALUES
	(1, 'abc', 120),
	(2, 'xyz', 120);
/*!40000 ALTER TABLE `NetOp` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
