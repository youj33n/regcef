
CREATE TABLE IF NOT EXISTS `accounts` (
  `id` int(11) NOT NULL,
  `name` varchar(64) NOT NULL,
  `password` varchar(64) NOT NULL,
  `mail` varchar(64) NOT NULL,
  `skin` int(3) NOT NULL DEFAULT '0',
  `gender` int(3) NOT NULL DEFAULT '0',
  `interface` int(3) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
