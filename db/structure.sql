CREATE TABLE `cars` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `driver_id` int(11) DEFAULT NULL,
  `make` varchar(255) DEFAULT NULL,
  `model` varchar(255) DEFAULT NULL,
  `license_plate` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `location` point DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `year` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_cars_on_location` (`location`(25))
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=latin1;

CREATE TABLE `devices` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `hardware` varchar(255) DEFAULT NULL,
  `os` varchar(255) DEFAULT NULL,
  `platform` varchar(255) DEFAULT NULL,
  `push_token` varchar(255) DEFAULT NULL,
  `uuid` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=56 DEFAULT CHARSET=latin1;

CREATE TABLE `driver_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `drivers_license_file_name` varchar(255) DEFAULT NULL,
  `drivers_license_content_type` varchar(255) DEFAULT NULL,
  `drivers_license_file_size` int(11) DEFAULT NULL,
  `drivers_license_updated_at` datetime DEFAULT NULL,
  `vehicle_registration_file_name` varchar(255) DEFAULT NULL,
  `vehicle_registration_content_type` varchar(255) DEFAULT NULL,
  `vehicle_registration_file_size` int(11) DEFAULT NULL,
  `vehicle_registration_updated_at` datetime DEFAULT NULL,
  `proof_of_insurance_file_name` varchar(255) DEFAULT NULL,
  `proof_of_insurance_content_type` varchar(255) DEFAULT NULL,
  `proof_of_insurance_file_size` int(11) DEFAULT NULL,
  `proof_of_insurance_updated_at` datetime DEFAULT NULL,
  `car_photo_file_name` varchar(255) DEFAULT NULL,
  `car_photo_content_type` varchar(255) DEFAULT NULL,
  `car_photo_file_size` int(11) DEFAULT NULL,
  `car_photo_updated_at` datetime DEFAULT NULL,
  `national_database_check_file_name` varchar(255) DEFAULT NULL,
  `national_database_check_content_type` varchar(255) DEFAULT NULL,
  `national_database_check_file_size` int(11) DEFAULT NULL,
  `national_database_check_updated_at` datetime DEFAULT NULL,
  `drivers_license_number` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=latin1;

CREATE TABLE `offered_rides` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `driver_id` int(11) DEFAULT NULL,
  `ride_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `state` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=604 DEFAULT CHARSET=latin1;

CREATE TABLE `ride_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `ride_id` int(11) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `request_type` varchar(255) DEFAULT NULL,
  `requested_datetime` datetime DEFAULT NULL,
  `origin` point DEFAULT NULL,
  `origin_place_name` varchar(255) DEFAULT NULL,
  `destination` point DEFAULT NULL,
  `destination_place_name` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `desired_arrival` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_ride_requests_on_origin` (`origin`(25)),
  KEY `index_ride_requests_on_destination` (`destination`(25)),
  KEY `ride_requests_ride_id_fk` (`ride_id`)
) ENGINE=InnoDB AUTO_INCREMENT=552 DEFAULT CHARSET=latin1;

CREATE TABLE `rider_rides` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `rider_id` int(11) DEFAULT NULL,
  `ride_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=322 DEFAULT CHARSET=latin1;

CREATE TABLE `rider_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=latin1;

CREATE TABLE `rides` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `driver_id` int(11) DEFAULT NULL,
  `car_id` int(11) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `scheduled` datetime DEFAULT NULL,
  `started` datetime DEFAULT NULL,
  `finished` datetime DEFAULT NULL,
  `meeting_point` point DEFAULT NULL,
  `meeting_point_place_name` varchar(255) DEFAULT NULL,
  `drop_off_point` point DEFAULT NULL,
  `drop_off_point_place_name` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `pickup_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_rides_on_meeting_point` (`meeting_point`(25)),
  KEY `index_rides_on_destination` (`drop_off_point`(25))
) ENGINE=InnoDB AUTO_INCREMENT=548 DEFAULT CHARSET=latin1;

CREATE TABLE `rpush_apps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `environment` varchar(255) DEFAULT NULL,
  `certificate` text,
  `password` varchar(255) DEFAULT NULL,
  `connections` int(11) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `type` varchar(255) NOT NULL,
  `auth_key` varchar(255) DEFAULT NULL,
  `client_id` varchar(255) DEFAULT NULL,
  `client_secret` varchar(255) DEFAULT NULL,
  `access_token` varchar(255) DEFAULT NULL,
  `access_token_expiration` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

CREATE TABLE `rpush_feedback` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `device_token` varchar(64) NOT NULL,
  `failed_at` datetime NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `app` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_rapns_feedback_on_device_token` (`device_token`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `rpush_notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `badge` int(11) DEFAULT NULL,
  `device_token` varchar(64) DEFAULT NULL,
  `sound` varchar(255) DEFAULT 'default',
  `alert` varchar(255) DEFAULT NULL,
  `data` text,
  `expiry` int(11) DEFAULT '86400',
  `delivered` tinyint(1) NOT NULL DEFAULT '0',
  `delivered_at` datetime DEFAULT NULL,
  `failed` tinyint(1) NOT NULL DEFAULT '0',
  `failed_at` datetime DEFAULT NULL,
  `error_code` int(11) DEFAULT NULL,
  `error_description` text,
  `deliver_after` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `alert_is_json` tinyint(1) DEFAULT '0',
  `type` varchar(255) NOT NULL,
  `collapse_key` varchar(255) DEFAULT NULL,
  `delay_while_idle` tinyint(1) NOT NULL DEFAULT '0',
  `registration_ids` mediumtext,
  `app_id` int(11) NOT NULL,
  `retries` int(11) DEFAULT '0',
  `uri` varchar(255) DEFAULT NULL,
  `fail_after` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_rapns_notifications_multi` (`app_id`,`delivered`,`failed`,`deliver_after`)
) ENGINE=InnoDB AUTO_INCREMENT=1133 DEFAULT CHARSET=latin1;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `stripe_customer_id` varchar(255) DEFAULT NULL,
  `stripe_recipient_id` varchar(255) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `is_driver` tinyint(1) DEFAULT NULL,
  `is_rider` tinyint(1) DEFAULT NULL,
  `commuter_balance_cents` int(11) DEFAULT NULL,
  `commuter_refill_amount_cents` int(11) DEFAULT NULL,
  `location` point DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `rider_location` point DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `referral_code` varchar(255) DEFAULT NULL,
  `salt` varchar(255) DEFAULT NULL,
  `token` varchar(255) DEFAULT NULL,
  `driver_request_region` varchar(255) DEFAULT NULL,
  `driver_referral_code` varchar(255) DEFAULT NULL,
  `webtoken` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_email` (`email`),
  KEY `index_users_on_location` (`location`(25))
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=latin1;

INSERT INTO schema_migrations (version) VALUES ('20140523011016');

INSERT INTO schema_migrations (version) VALUES ('20140523011018');

INSERT INTO schema_migrations (version) VALUES ('20140523011309');

INSERT INTO schema_migrations (version) VALUES ('20140523011345');

INSERT INTO schema_migrations (version) VALUES ('20140523011347');

INSERT INTO schema_migrations (version) VALUES ('20140523011350');

INSERT INTO schema_migrations (version) VALUES ('20140523224324');

INSERT INTO schema_migrations (version) VALUES ('20140523231216');

INSERT INTO schema_migrations (version) VALUES ('20140524014750');

INSERT INTO schema_migrations (version) VALUES ('20140524030533');

INSERT INTO schema_migrations (version) VALUES ('20140524033522');

INSERT INTO schema_migrations (version) VALUES ('20140524040642');

INSERT INTO schema_migrations (version) VALUES ('20140527201119');

INSERT INTO schema_migrations (version) VALUES ('20140528000417');

INSERT INTO schema_migrations (version) VALUES ('20140529231120');

INSERT INTO schema_migrations (version) VALUES ('20140609032342');

INSERT INTO schema_migrations (version) VALUES ('20140609032948');

INSERT INTO schema_migrations (version) VALUES ('20140609033003');

INSERT INTO schema_migrations (version) VALUES ('20140609033104');

INSERT INTO schema_migrations (version) VALUES ('20140609055440');

INSERT INTO schema_migrations (version) VALUES ('20140609060248');

INSERT INTO schema_migrations (version) VALUES ('20140609194806');

INSERT INTO schema_migrations (version) VALUES ('20140609195636');

INSERT INTO schema_migrations (version) VALUES ('20140609195705');

INSERT INTO schema_migrations (version) VALUES ('20140609200048');

INSERT INTO schema_migrations (version) VALUES ('20140609200128');

INSERT INTO schema_migrations (version) VALUES ('20140609200135');

INSERT INTO schema_migrations (version) VALUES ('20140609222744');

INSERT INTO schema_migrations (version) VALUES ('20140610001847');

INSERT INTO schema_migrations (version) VALUES ('20140618203022');

INSERT INTO schema_migrations (version) VALUES ('20140619051846');

INSERT INTO schema_migrations (version) VALUES ('20140619052055');

INSERT INTO schema_migrations (version) VALUES ('20140619071122');

INSERT INTO schema_migrations (version) VALUES ('20140619071629');

INSERT INTO schema_migrations (version) VALUES ('20140619072814');

INSERT INTO schema_migrations (version) VALUES ('20140628071158');

INSERT INTO schema_migrations (version) VALUES ('20140703064003');

INSERT INTO schema_migrations (version) VALUES ('20140707205309');