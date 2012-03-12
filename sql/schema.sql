/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;

-- -----------------------------------------------------------------------------

-- countdowns
CREATE TABLE `countdowns` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `target_date` datetime NOT NULL,
  `units` varchar(255) NOT NULL DEFAULT 'day',
  `on_homepage` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

-- entries
CREATE TABLE `entries` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `task_date` date NOT NULL DEFAULT '0000-00-00',
  `entry_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `ticket_num` varchar(255) DEFAULT NULL,
  `subject` varchar(255) NOT NULL DEFAULT '',
  `description` text NOT NULL,
  `category` varchar(255) NOT NULL DEFAULT 'Other',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`)
) ENGINE=MyISAM;

-- lists
CREATE TABLE `lists` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

-- notes
CREATE TABLE `notes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `created_date` datetime NOT NULL,
  `updated_date` datetime NOT NULL,
  `body` text NOT NULL,
  `is_favorite` tinyint(1) NOT NULL DEFAULT '0',
  `is_encrypted` tinyint(1) NOT NULL DEFAULT '0',
  `deleted_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

-- preferences
CREATE TABLE `preferences` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL DEFAULT '',
  `value` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_prefs_name` (`name`),
  KEY `fk_prefs_user_id` (`user_id`),
  CONSTRAINT `fk_prefs_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB;

-- schema_migrations
CREATE TABLE `schema_migrations` (
  `version` bigint(20) unsigned NOT NULL DEFAULT '0',
  `applied_date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  UNIQUE KEY `uk_version` (`version`)
) ENGINE=InnoDB;

-- todos
CREATE TABLE `todos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `priority` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `completed` tinyint(1) NOT NULL DEFAULT '0',
  `completed_date` datetime DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `list_id` int(11) DEFAULT NULL,
  `description` varchar(1024) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

-- users
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `user_name` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

-- work_days
CREATE TABLE `work_days` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `work_date` date NOT NULL,
  `time_in` time NOT NULL,
  `time_out` time NOT NULL,
  `note` varchar(255) DEFAULT NULL,
  `is_vacation` tinyint(1) NOT NULL DEFAULT '0',
  `is_holiday` tinyint(1) NOT NULL DEFAULT '0',
  `is_sick_day` tinyint(1) NOT NULL DEFAULT '0',
  `time_lunch` time NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------

/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;

