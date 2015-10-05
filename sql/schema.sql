/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;

-- -----------------------------------------------------------------------------

-- countdowns
CREATE TABLE `countdowns` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `units` varchar(255) NOT NULL DEFAULT 'day',
  `on_homepage` tinyint(1) NOT NULL DEFAULT '0',
  `is_real_time` tinyint(1) NOT NULL DEFAULT '0',
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
  `time_spent` time NOT NULL DEFAULT '00:00:00',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB;

-- lists
CREATE TABLE `lists` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

-- notes
CREATE TABLE `notes` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
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
  `user_id` bigint(20) unsigned NOT NULL DEFAULT '0',
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

-- stickies
CREATE TABLE `stickies` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `body` text NOT NULL,
  `created_date` datetime NOT NULL,
  `updated_date` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

-- tagged_object
CREATE TABLE `tagged_object` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tag_id` bigint(20) unsigned NOT NULL,
  `obj_class` varchar(64) NOT NULL,
  `obj_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tag_obj` (`tag_id`,`obj_class`,`obj_id`),
  CONSTRAINT `fk_tags_assoc_tag_id` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`id`)
) ENGINE=InnoDB;

-- tags
CREATE TABLE `tags` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tags_name` (`name`)
) ENGINE=InnoDB;

-- todos
CREATE TABLE `todos` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `priority` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `completed` tinyint(1) NOT NULL DEFAULT '0',
  `completed_date` datetime DEFAULT NULL,
  `due_date` datetime DEFAULT NULL,
  `list_id` bigint(20) unsigned DEFAULT NULL,
  `description` varchar(1024) DEFAULT NULL,
  `repeat_duration` varchar(16) DEFAULT NULL,
  `parent_id` bigint(20) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

-- users
CREATE TABLE `users` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `user_name` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL DEFAULT '',
  `location` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

-- work_days
CREATE TABLE `work_days` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
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

