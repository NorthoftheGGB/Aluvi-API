CREATE TABLE `cars` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `make` varchar(255) DEFAULT NULL,
  `model` varchar(255) DEFAULT NULL,
  `license_plate` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `location` point DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_cars_on_location` (`location`(25))
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

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
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `offered_rides` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `driver_id` int(11) DEFAULT NULL,
  `ride_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `state` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
  PRIMARY KEY (`id`),
  KEY `index_ride_requests_on_origin` (`origin`(25)),
  KEY `index_ride_requests_on_destination` (`destination`(25))
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=latin1;

CREATE TABLE `rider_rides` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `rider_id` int(11) DEFAULT NULL,
  `ride_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
  `destination` point DEFAULT NULL,
  `destination_place_name` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `pickup_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_rides_on_meeting_point` (`meeting_point`(25)),
  KEY `index_rides_on_destination` (`destination`(25))
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=latin1;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `stripe_customer_id` int(11) DEFAULT NULL,
  `stripe_recipient_id` int(11) DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `is_driver` tinyint(1) DEFAULT NULL,
  `is_rider` tinyint(1) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `commuter_balance_cents` int(11) DEFAULT NULL,
  `commuter_refill_amount_cents` int(11) DEFAULT NULL,
  `location` point DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `rider_location` point DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_users_on_location` (`location`(25))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

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