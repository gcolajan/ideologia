-- phpMyAdmin SQL Dump
-- version 3.4.10.1deb1
-- http://www.phpmyadmin.net
--
-- Client: localhost
-- Généré le : Ven 09 Août 2013 à 22:28
-- Version du serveur: 5.5.32
-- Version de PHP: 5.3.10-1ubuntu3.7

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Base de données: `nf`
--

-- --------------------------------------------------------

--
-- Structure de la table `ideo_evenement_effet`
--

CREATE TABLE IF NOT EXISTS `ideo_evenement_effet` (
  `ee_operation_id` int(11) NOT NULL,
  `ee_jauge_id` int(11) NOT NULL,
  `ee_variation_absolue` int(11) NOT NULL,
  `ee_variation_pourcentage` float NOT NULL,
  PRIMARY KEY (`ee_operation_id`,`ee_jauge_id`),
  KEY `ee_jauge_id` (`ee_jauge_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Contenu de la table `ideo_evenement_effet`
--

INSERT INTO `ideo_evenement_effet` (`ee_operation_id`, `ee_jauge_id`, `ee_variation_absolue`, `ee_variation_pourcentage`) VALUES
(1, 1, 0, 0.95),
(1, 2, 0, 0.97),
(1, 3, 0, 0.93),
(2, 1, -7, 1),
(2, 2, 0, 1.5),
(2, 3, 0, 1.05),
(3, 1, 6, 1),
(3, 2, 0, 0.9),
(4, 1, 0, 1.05),
(4, 3, -3, 1);

-- --------------------------------------------------------

--
-- Structure de la table `ideo_evenement_operation`
--

CREATE TABLE IF NOT EXISTS `ideo_evenement_operation` (
  `eo_id` int(11) NOT NULL AUTO_INCREMENT,
  `eo_nom` varchar(32) NOT NULL,
  `eo_description` varchar(255) NOT NULL,
  `eo_destination` tinyint(4) NOT NULL,
  PRIMARY KEY (`eo_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=5 ;

--
-- Contenu de la table `ideo_evenement_operation`
--

INSERT INTO `ideo_evenement_operation` (`eo_id`, `eo_nom`, `eo_description`, `eo_destination`) VALUES
(1, 'Séisme', 'Un séisme de grande magnitude a secoué le monde entier', 0),
(2, 'Crack boursier', 'L''économie s''est effondré pendant la nuit', 0),
(3, 'Découverte', 'Vous avez découvert une mine de pétrole', 1),
(4, 'Explosion de l''ambassade', 'L''ambassade de votre territoire vient d''exploser', 1);

-- --------------------------------------------------------

--
-- Structure de la table `ideo_ideologie`
--

CREATE TABLE IF NOT EXISTS `ideo_ideologie` (
  `ideo_id` int(11) NOT NULL AUTO_INCREMENT,
  `ideo_nom` varchar(32) NOT NULL,
  `ideo_couleur` varchar(6) NOT NULL,
  `ideo_pion` varchar(32) NOT NULL,
  PRIMARY KEY (`ideo_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=5 ;

--
-- Contenu de la table `ideo_ideologie`
--

INSERT INTO `ideo_ideologie` (`ideo_id`, `ideo_nom`, `ideo_couleur`, `ideo_pion`) VALUES
(1, 'Anarchisme', '8000FF', ''),
(2, 'Communisme', 'FF0000', ''),
(3, 'Économie féodale', '80FF00', ''),
(4, 'Libéralisme', '00FFFF', '');

-- --------------------------------------------------------

--
-- Structure de la table `ideo_jauge`
--

CREATE TABLE IF NOT EXISTS `ideo_jauge` (
  `jauge_id` int(11) NOT NULL AUTO_INCREMENT,
  `jauge_nom` varchar(32) NOT NULL,
  PRIMARY KEY (`jauge_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=4 ;

--
-- Contenu de la table `ideo_jauge`
--

INSERT INTO `ideo_jauge` (`jauge_id`, `jauge_nom`) VALUES
(1, 'Économique'),
(2, 'Environnementale'),
(3, 'Sociale');

-- --------------------------------------------------------

--
-- Structure de la table `ideo_jauge_caracteristique`
--

CREATE TABLE IF NOT EXISTS `ideo_jauge_caracteristique` (
  `caract_ideo_id` int(11) NOT NULL,
  `caract_jauge_id` int(11) NOT NULL,
  `caract_coeff_diminution` float NOT NULL,
  `caract_coeff_augmentation` float NOT NULL,
  `caract_ideal` float NOT NULL,
  PRIMARY KEY (`caract_jauge_id`,`caract_ideo_id`),
  KEY `ideo_jauge_caract_ibfk_2` (`caract_ideo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Contenu de la table `ideo_jauge_caracteristique`
--

INSERT INTO `ideo_jauge_caracteristique` (`caract_ideo_id`, `caract_jauge_id`, `caract_coeff_diminution`, `caract_coeff_augmentation`, `caract_ideal`) VALUES
(1, 1, 1, 1, 0.3),
(2, 1, 1, 1, 0.6),
(3, 1, 1, 1, 0.4),
(4, 1, 1, 1, 0.8),
(1, 2, 1, 1, 0.5),
(2, 2, 1, 1, 0.2),
(3, 2, 1, 1, 0.5),
(4, 2, 1, 1, 0.3),
(1, 3, 1, 1, 0.8),
(2, 3, 1, 1, 0.6),
(3, 3, 1, 1, 0.6),
(4, 3, 1, 1, 0.4);

-- --------------------------------------------------------

--
-- Structure de la table `ideo_score`
--

CREATE TABLE IF NOT EXISTS `ideo_score` (
  `score_id` int(11) NOT NULL AUTO_INCREMENT,
  `score_date` datetime NOT NULL,
  `score_pseudo` varchar(32) NOT NULL,
  `score_ideologie_id` int(11) NOT NULL,
  `score_respect_ideologie` float NOT NULL,
  `score_domination_geo` float NOT NULL,
  PRIMARY KEY (`score_id`),
  KEY `score_date` (`score_date`,`score_respect_ideologie`),
  KEY `score_date_2` (`score_date`,`score_domination_geo`),
  KEY `score_ideologie_id` (`score_ideologie_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=21 ;

--
-- Contenu de la table `ideo_score`
--

INSERT INTO `ideo_score` (`score_id`, `score_date`, `score_pseudo`, `score_ideologie_id`, `score_respect_ideologie`, `score_domination_geo`) VALUES
(5, '2013-03-26 18:28:22', 'A', 1, 14.2857, 0.21875),
(6, '2013-03-26 18:28:22', 'B', 2, 8.44444, 0.28125),
(7, '2013-03-26 18:28:22', 'C', 3, 15.5, 0.25),
(8, '2013-03-26 18:28:22', 'D', 4, 11.75, 0.25);

-- --------------------------------------------------------

--
-- Structure de la table `ideo_territoire_effet`
--

CREATE TABLE IF NOT EXISTS `ideo_territoire_effet` (
  `te_operation_id` int(11) NOT NULL,
  `te_jauge_id` int(11) NOT NULL,
  `te_ideologie_id` int(11) NOT NULL,
  `te_variation_absolue` int(11) NOT NULL,
  `te_variation_pourcentage` float NOT NULL,
  PRIMARY KEY (`te_operation_id`,`te_jauge_id`,`te_ideologie_id`),
  KEY `te_jauge_id` (`te_jauge_id`),
  KEY `te_ideologie_id` (`te_ideologie_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Contenu de la table `ideo_territoire_effet`
--

INSERT INTO `ideo_territoire_effet` (`te_operation_id`, `te_jauge_id`, `te_ideologie_id`, `te_variation_absolue`, `te_variation_pourcentage`) VALUES
(1, 1, 1, -3, 1),
(1, 1, 2, 5, 1),
(1, 1, 3, 2, 1),
(1, 1, 4, 3, 1),
(1, 3, 1, -5, 1),
(1, 3, 3, 3, 1),
(1, 3, 4, -5, 1),
(2, 1, 1, 0, 1.052),
(2, 1, 2, 0, 1.052),
(2, 1, 3, 0, 1.052),
(2, 1, 4, 4, 1),
(2, 2, 1, -4, 1),
(2, 2, 2, -3, 1),
(2, 2, 3, -3, 1),
(2, 2, 4, -2, 1),
(2, 3, 1, -4, 1),
(2, 3, 2, 0, 1.052),
(2, 3, 3, 0, 1.052),
(2, 3, 4, 3, 1),
(5, 1, 1, -3, 1),
(5, 1, 2, -4, 1),
(5, 1, 3, -3, 1),
(5, 1, 4, 3, 1),
(5, 2, 1, -1, 1),
(5, 2, 2, 2, 1),
(5, 2, 3, -3, 1),
(5, 2, 4, -2, 1),
(5, 3, 1, 4, 1),
(5, 3, 2, -3, 1),
(5, 3, 3, -2, 1),
(5, 3, 4, -3, 1),
(6, 1, 1, 3, 1),
(6, 1, 2, 3, 1),
(6, 1, 3, 3, 1),
(6, 1, 4, 3, 1),
(6, 3, 1, 4, 1),
(6, 3, 2, 4, 1),
(6, 3, 3, 4, 1),
(6, 3, 4, 4, 1),
(7, 1, 1, 10, 1),
(7, 1, 2, 8, 1),
(7, 1, 3, 4, 1),
(7, 1, 4, 5, 1),
(7, 2, 1, -5, 1),
(7, 2, 2, -4, 1),
(7, 2, 3, -3, 1),
(7, 2, 4, -5, 1),
(7, 3, 1, -6, 1),
(7, 3, 2, -3, 1),
(7, 3, 3, -2, 1),
(7, 3, 4, -3, 1),
(8, 1, 1, -4, 1),
(8, 1, 2, 5, 1),
(8, 1, 3, 3, 1),
(8, 1, 4, -2, 1),
(8, 2, 1, -5, 1),
(8, 2, 2, -4, 1),
(8, 2, 3, -2, 1),
(8, 2, 4, -4, 1),
(8, 3, 4, 3, 1),
(9, 1, 2, 3, 1),
(9, 1, 4, 6, 1),
(9, 2, 2, 3, 1),
(9, 2, 3, 3, 1),
(9, 2, 4, 2, 1),
(9, 3, 2, 5, 1),
(9, 3, 3, 2, 1),
(9, 3, 4, 5, 1),
(10, 1, 1, 5, 1),
(10, 1, 2, 3, 1),
(10, 1, 3, 4, 1),
(10, 1, 4, 3, 1),
(10, 2, 1, -7, 1),
(10, 2, 2, -5, 1),
(10, 2, 3, -5, 1),
(10, 2, 4, -5, 1),
(10, 3, 1, -2, 1),
(10, 3, 3, 3, 1),
(10, 3, 4, -3, 1),
(11, 1, 1, -4, 1),
(11, 1, 2, -3, 1),
(11, 1, 4, -3, 1),
(11, 2, 1, 3, 1),
(11, 2, 2, 4, 1),
(11, 2, 3, 5, 1),
(11, 2, 4, 5, 1),
(11, 3, 2, 3, 1),
(11, 3, 4, 3, 1),
(12, 1, 1, -3, 1),
(12, 1, 2, -3, 1),
(12, 1, 3, -3, 1),
(12, 2, 1, 5, 1),
(12, 2, 2, 5, 1),
(12, 2, 3, 5, 1),
(12, 3, 1, 3, 1),
(12, 3, 2, 3, 1),
(12, 3, 3, 3, 1),
(13, 1, 1, -3, 1),
(13, 1, 2, -3, 1),
(13, 1, 3, -3, 1),
(13, 1, 4, -3, 1),
(13, 2, 1, -3, 1),
(13, 2, 2, -3, 1),
(13, 2, 3, -3, 1),
(13, 2, 4, -3, 1),
(13, 3, 1, -3, 1),
(13, 3, 2, -3, 1),
(13, 3, 3, -3, 1),
(13, 3, 4, -3, 1),
(14, 1, 1, 0, 0.9),
(14, 1, 2, 0, 0.9),
(14, 1, 3, 0, 0.9),
(14, 1, 4, 0, 0.9),
(14, 3, 1, 0, 0.9),
(14, 3, 2, 0, 0.9),
(14, 3, 3, 0, 0.9),
(14, 3, 4, 0, 0.9),
(15, 1, 1, 5, 1),
(15, 1, 2, 3, 1),
(15, 1, 3, 3, 1),
(15, 1, 4, 3, 1),
(15, 2, 1, -5, 1),
(15, 2, 2, -3, 1),
(15, 2, 3, -2, 1),
(15, 2, 4, -5, 1),
(15, 3, 2, 2, 1),
(15, 3, 3, 2, 1),
(15, 3, 4, 3, 1),
(16, 1, 1, 3, 1),
(16, 1, 2, 3, 1),
(16, 1, 3, 3, 1),
(16, 1, 4, 3, 1),
(16, 3, 1, -4, 1),
(16, 3, 2, -4, 1),
(16, 3, 3, -4, 1),
(16, 3, 4, -4, 1),
(17, 1, 1, 3, 1),
(17, 1, 2, -3, 1),
(17, 1, 3, -3, 1),
(17, 1, 4, 3, 1),
(17, 2, 1, -3, 1),
(17, 2, 2, -3, 1),
(17, 2, 3, -3, 1),
(17, 3, 1, 4, 1),
(17, 3, 2, 5, 1),
(17, 3, 3, -3, 1),
(17, 3, 4, 4, 1),
(18, 1, 1, -3, 1),
(18, 1, 2, -3, 1),
(18, 1, 3, -3, 1),
(18, 1, 4, 3, 1),
(18, 3, 1, 4, 1),
(18, 3, 2, 2, 1),
(18, 3, 3, 2, 1),
(18, 3, 4, 3, 1),
(19, 3, 1, 0, 0.98),
(19, 3, 2, 0, 0.98),
(19, 3, 3, 0, 0.98),
(19, 3, 4, 0, 0.98),
(20, 1, 1, 5, 1),
(20, 1, 2, 5, 1),
(20, 1, 3, 5, 1),
(20, 1, 4, 5, 1),
(20, 2, 1, -2, 1),
(20, 2, 2, -2, 1),
(20, 2, 3, -2, 1),
(20, 2, 4, -2, 1),
(20, 3, 1, -2, 1),
(20, 3, 2, -2, 1),
(20, 3, 3, -2, 1),
(20, 3, 4, -2, 1),
(21, 1, 1, 3, 1),
(21, 1, 2, 3, 1),
(21, 1, 3, 3, 1),
(21, 1, 4, 3, 1),
(21, 2, 1, 3, 1),
(21, 2, 2, 3, 1),
(21, 2, 3, 3, 1),
(21, 2, 4, 3, 1),
(22, 1, 4, 4, 1),
(22, 2, 1, 3, 1),
(22, 2, 2, 3, 1),
(22, 2, 3, 3, 1),
(22, 2, 4, 3, 1),
(22, 3, 1, 5, 1),
(22, 3, 2, 5, 1),
(22, 3, 3, 5, 1),
(22, 3, 4, 5, 1),
(23, 1, 1, 2, 1),
(23, 1, 4, -3, 1),
(23, 3, 1, 2, 1),
(23, 3, 2, 2, 1),
(23, 3, 3, 2, 1),
(23, 3, 4, 2, 1),
(24, 1, 1, 3, 1),
(24, 1, 2, -3, 1),
(24, 1, 3, -3, 1),
(24, 1, 4, -3, 1),
(24, 2, 1, 3, 1),
(24, 3, 1, 3, 1),
(24, 3, 2, -3, 1),
(24, 3, 3, -3, 1),
(24, 3, 4, -3, 1);

-- --------------------------------------------------------

--
-- Structure de la table `ideo_territoire_operation`
--

CREATE TABLE IF NOT EXISTS `ideo_territoire_operation` (
  `to_id` int(11) NOT NULL AUTO_INCREMENT,
  `to_nom` varchar(32) NOT NULL,
  `to_description` varchar(255) NOT NULL,
  PRIMARY KEY (`to_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=25 ;

--
-- Contenu de la table `ideo_territoire_operation`
--

INSERT INTO `ideo_territoire_operation` (`to_id`, `to_nom`, `to_description`) VALUES
(1, 'Censure', 'Vous allez mettre en place une censure sur votre territoire'),
(2, 'Propagande', 'Vous lancez une campagne de propagande sur le territoire'),
(6, 'Intérêts', 'Vous réclamez les intérêts à ce territoire'),
(7, 'Essai nucléaire', 'Vous faîtes des essais nucléaires'),
(8, 'Lancement d''une fusée', 'Vous essayez d''envoyer une fusée dans l''espace'),
(9, 'Election d''un nouveau président', 'Vous allez élire un nouveau président'),
(10, 'Déforestation', 'Vous coupez du bois en grande quantité'),
(11, 'Subvention aux énergies vertes', 'Vous versez une subvention pour les énergies vertes'),
(12, 'Protection des forêts', 'Vous mettez en place des protections contre le braconage'),
(13, 'Incendie volontaire', 'Vous mettez le feu volontairement à la forêt'),
(14, 'Blocus économique', 'Vous mettez en place un blocus économique'),
(15, 'Vente d''une mine de charbon', 'Vous vendez une mine de charbon'),
(16, 'Hausse des taxes', 'Vous allez faire payer vos citoyens plus cher'),
(24, 'Enlèvement du président', 'Vous enlevez le président');

-- --------------------------------------------------------

--
-- Structure de la table `ideo_territoire_operation_cout`
--

CREATE TABLE IF NOT EXISTS `ideo_territoire_operation_cout` (
  `toc_operation_id` int(11) NOT NULL,
  `toc_ideologie_id` int(11) NOT NULL,
  `toc_cout` int(11) NOT NULL,
  PRIMARY KEY (`toc_operation_id`,`toc_ideologie_id`),
  KEY `toc_ideologie_id` (`toc_ideologie_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Contenu de la table `ideo_territoire_operation_cout`
--

INSERT INTO `ideo_territoire_operation_cout` (`toc_operation_id`, `toc_ideologie_id`, `toc_cout`) VALUES
(1, 1, 200),
(1, 2, 200),
(1, 3, 200),
(1, 4, 200),
(2, 1, 150),
(2, 2, 150),
(2, 3, 150),
(2, 4, 150),
(6, 1, -150),
(6, 2, -150),
(6, 3, -150),
(6, 4, -150),
(7, 1, 500),
(7, 2, 500),
(7, 3, 500),
(7, 4, 500),
(8, 1, 450),
(8, 2, 450),
(8, 3, 450),
(8, 4, 450),
(9, 2, 300),
(9, 3, 300),
(9, 4, 300),
(10, 1, 150),
(10, 2, 150),
(10, 3, 150),
(10, 4, 150),
(11, 1, 200),
(11, 2, 200),
(11, 3, 200),
(11, 4, 200),
(12, 1, 200),
(12, 2, 200),
(12, 3, 200),
(13, 1, 100),
(13, 2, 100),
(13, 3, 100),
(13, 4, 100),
(14, 1, 150),
(14, 2, 150),
(14, 3, 150),
(14, 4, 150),
(15, 1, -200),
(15, 2, -200),
(15, 3, -200),
(15, 4, -200),
(16, 1, -300),
(16, 2, -300),
(16, 3, -300),
(16, 4, -300),
(24, 1, 100),
(24, 2, 100),
(24, 3, 100),
(24, 4, 100);

-- --------------------------------------------------------

--
-- Structure de la table `terr_continent`
--

CREATE TABLE IF NOT EXISTS `terr_continent` (
  `continent_id` tinyint(4) NOT NULL AUTO_INCREMENT,
  `continent_nom` varchar(32) NOT NULL,
  PRIMARY KEY (`continent_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=8 ;

--
-- Contenu de la table `terr_continent`
--

INSERT INTO `terr_continent` (`continent_id`, `continent_nom`) VALUES
(1, 'Amérique du Nord'),
(2, 'Amérique du Sud'),
(3, 'Antarctique'),
(4, 'Asie'),
(5, 'Europe'),
(6, 'Afrique'),
(7, 'Océanie');

-- --------------------------------------------------------

--
-- Structure de la table `terr_territoire`
--

CREATE TABLE IF NOT EXISTS `terr_territoire` (
  `terr_id` tinyint(4) NOT NULL AUTO_INCREMENT,
  `terr_nom` varchar(32) NOT NULL,
  `terr_position` tinyint(4) NOT NULL,
  PRIMARY KEY (`terr_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=33 ;

--
-- Contenu de la table `terr_territoire`
--

INSERT INTO `terr_territoire` (`terr_id`, `terr_nom`, `terr_position`) VALUES
(1, 'Europe du Sud', 9),
(2, 'Europe du Nord', 34),
(3, 'Europe occidentale', 8),
(4, 'Amérique centrale', 18),
(5, 'Amérique du Nord', 6),
(6, 'Cordilière des Andes', 14),
(7, 'Amérique atlantico-latine', 28),
(8, 'Territoire no11', 11),
(9, 'Afrique du Sud', 37),
(10, 'Afrique du Nord-Est', 40),
(11, 'Afrique centrale', 35),
(12, 'Afrique de l''Ouest', 2),
(13, 'Territoire no20', 20),
(14, 'Proche-Orient', 26),
(15, 'Pacifique du Sud-Ouest', 39),
(16, 'Asie du Sud-Est', 15),
(17, 'Péninsule indochinoise', 1),
(18, 'Territoire no13', 13),
(19, 'Territoire no38', 38),
(20, 'Ex-URSS', 3),
(21, 'Territoire no36', 36),
(22, 'Territoire no33', 33),
(23, 'Territoire no19', 19),
(24, 'Territoire no5', 5),
(25, 'Territoire no25', 25),
(26, 'Territoire no32', 32),
(27, 'Inde du Sud', 22),
(28, 'Territoire no12', 12),
(29, 'Territoire no31', 31),
(30, 'Territoire no16', 16),
(31, 'Territoire no7', 7),
(32, 'Moyen-Orient', 27);

-- --------------------------------------------------------

--
-- Structure de la table `terr_unite`
--

CREATE TABLE IF NOT EXISTS `terr_unite` (
  `unite_id` int(11) NOT NULL AUTO_INCREMENT,
  `unite_nom` varchar(34) DEFAULT NULL,
  `unite_population` int(11) DEFAULT NULL,
  `unite_superficie` int(11) DEFAULT NULL,
  `unite_continent` tinyint(4) NOT NULL,
  `unite_territoire` tinyint(4) DEFAULT NULL,
  PRIMARY KEY (`unite_id`),
  KEY `unite_continent` (`unite_continent`),
  KEY `unite_territoire` (`unite_territoire`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=382 ;

--
-- Contenu de la table `terr_unite`
--

INSERT INTO `terr_unite` (`unite_id`, `unite_nom`, `unite_population`, `unite_superficie`, `unite_continent`, `unite_territoire`) VALUES
(1, 'Brésil', 192298177, 8547877, 2, 7),
(2, 'Pakistan', 175790659, 796096, 4, 31),
(3, 'Nigéria', 165822569, 923768, 6, 8),
(4, 'Bangladesh', 150175596, 142615, 4, 25),
(5, 'Russie', 143030106, 17098242, 4, 20),
(6, 'Japon', 127470060, 377944, 4, 13),
(7, 'Mexique', 112322757, 1972550, 1, 4),
(8, 'Philippines', 92233337, 300439, 4, 15),
(9, 'Viêt Nam', 86024600, 331051, 4, 17),
(10, 'Ethiopie', 82101998, 1127127, 6, 10),
(11, 'Egypte', 82079636, 1001449, 6, 10),
(12, 'Allemagne', 81471834, 357046, 5, 2),
(13, 'Turquie', 74724269, 783562, 4, 14),
(14, 'Iran', 72769694, 1648195, 4, 32),
(15, 'République démocratique du Congo', 68692542, 2344798, 6, 11),
(16, 'Thaïlande', 67462281, 513120, 4, 16),
(17, 'France', 63460768, 551695, 5, 3),
(18, 'Royaume-Uni', 61524872, 243305, 5, 3),
(19, 'Italie', 60017677, 301336, 5, 1),
(20, 'Birmanie (Myanmar)', 53999804, 676578, 4, 24),
(21, 'Afrique du Sud', 50586757, 1219912, 6, 9),
(22, 'Corée du Sud', 50059999, 99828, 4, 13),
(23, 'Ukraine', 46162805, 603628, 5, 1),
(24, 'Espagne', 45989016, 506030, 5, 3),
(25, 'Colombie', 45566856, 1141748, 2, 6),
(26, 'Tanzanie', 41048532, 945088, 6, 11),
(27, 'Argentine', 40091359, 2791810, 2, 6),
(28, 'Pologne', 38112212, 312685, 5, 2),
(29, 'Kenya', 37953838, 581787, 6, 11),
(30, 'Algérie', 36275358, 2381741, 6, 12),
(31, 'Canada', 34605346, 9970610, 1, 5),
(32, 'Maroc', 34343219, 458730, 6, 12),
(33, 'Afghanistan', 32738376, 645806, 4, 32),
(34, 'Ouganda', 32369558, 241548, 6, 11),
(35, 'Soudan', 31957965, 1886065, 6, 10),
(36, 'Pérou', 29546963, 1285220, 2, 6),
(37, 'Ouzbékistan', 28765407, 447400, 4, 32),
(38, 'Malaisie', 28582848, 330803, 4, 16),
(39, 'Irak', 28221181, 434128, 4, 32),
(40, 'Népal', 27670558, 147181, 4, 24),
(41, 'Venezuela', 26414815, 916445, 2, 6),
(42, 'Arabie saoudite', 26131703, 2149690, 4, 14),
(43, 'Yémen', 24771809, 527970, 4, 14),
(44, 'Corée du Nord', 24457492, 122762, 4, 13),
(45, 'Ghana', 23382848, 238538, 6, 12),
(46, 'Taïwan', 23069345, 36191, 4, 18),
(47, 'Australie', 22585093, 7682557, 4, 15),
(48, 'Côte d''Ivoire', 21990009, 322462, 6, 12),
(49, 'Mozambique', 21669278, 801590, 6, 9),
(50, 'Roumanie', 21524042, 238391, 5, 1),
(51, 'Sri Lanka', 21324791, 64454, 4, 27),
(52, 'Syrie', 21160016, 185180, 4, 14),
(53, 'Angola', 20901811, 1246700, 6, 9),
(55, 'Cameroun', 18879301, 475442, 6, 9),
(56, 'Chili', 16928873, 756950, 2, 6),
(57, 'Burkina Faso', 16751455, 274200, 6, 12),
(58, 'Pays-Bas', 16738202, 41526, 5, 2),
(59, 'Mali', 16154923, 1240198, 6, 12),
(60, 'Niger', 15730754, 1267000, 6, 8),
(61, 'Malawi', 15447500, 118484, 6, 9),
(62, 'Kazakhstan', 15399437, 2717300, 4, 20),
(63, 'Equateur', 14573101, 283580, 2, 6),
(64, 'Cambodge', 13595100, 181035, 4, 17),
(65, 'Guatemala', 13002206, 109117, 1, 4),
(66, 'Sénégal', 12855153, 196712, 6, 12),
(67, 'Zimbabwe', 12382920, 390757, 6, 9),
(68, 'Zambie', 11862740, 752618, 6, 9),
(70, 'Tchad', 11274106, 1284200, 6, 9),
(71, 'Belgique', 11076847, 30528, 5, 2),
(72, 'Grèce', 10787690, 131957, 5, 1),
(73, 'Portugal', 10707924, 91906, 5, 3),
(74, 'Tunisie', 10629186, 163610, 6, 12),
(75, 'Rwanda', 10473282, 26798, 6, 11),
(76, 'République tchèque', 10446157, 78866, 5, 2),
(77, 'Guinée', 10324025, 245857, 6, 12),
(78, 'Bolivie', 10118683, 1098581, 2, 6),
(80, 'Hongrie', 9905596, 93030, 5, 1),
(81, 'Somalie', 9832017, 637657, 6, 10),
(83, 'Biélorussie', 9577552, 207600, 5, 2),
(84, 'Bénin', 9325032, 112622, 6, 8),
(85, 'Soudan du Sud', 9321443, 644329, 6, 11),
(86, 'Suède', 9276509, 449964, 5, 2),
(87, 'Azerbaïdjan', 9099035, 86600, 4, 32),
(88, 'Burundi', 8691005, 27834, 6, 11),
(89, 'Emirats arabes unis', 8458455, 82880, 4, 14),
(90, 'Autriche', 8416269, 83858, 5, 1),
(91, 'Suisse', 7952600, 41285, 5, 1),
(92, 'Honduras', 7833696, 112492, 1, 4),
(93, 'Israël', 7411000, 20517, 4, 14),
(94, 'Serbie', 7379339, 77474, 5, 1),
(95, 'Bulgarie', 7351234, 110912, 5, 1),
(96, 'Tadjikistan', 7349145, 143100, 4, 32),
(97, 'Hong Kong', 7122508, 1104, 4, 18),
(98, 'Paraguay', 6932613, 406752, 2, 6),
(99, 'Laos', 6677534, 236800, 4, 17),
(100, 'Libye', 6597960, 1759754, 6, 12),
(101, 'Jordanie', 6407085, 92300, 4, 14),
(103, 'Sierra Leone', 6294774, 71740, 6, 12),
(104, 'Salvador', 6052064, 21040, 1, 4),
(105, 'Nicaragua', 5891199, 129495, 1, 4),
(106, 'Togo', 5753324, 56785, 6, 8),
(107, 'Erythrée', 5647168, 121320, 6, 10),
(108, 'Danemark', 5566856, 43098, 5, 2),
(109, 'Kirghizistan', 5508626, 199900, 4, 32),
(110, 'Slovaquie', 5410371, 49034, 5, 1),
(111, 'Finlande', 5403808, 338145, 5, 2),
(112, 'Turkménistan', 5342342, 488100, 4, 32),
(113, 'Norvège', 4937305, 385186, 5, 2),
(114, 'Géorgie', 4714816, 69700, 4, 32),
(115, 'Bosnie-et-Herzégovine', 4621598, 51129, 5, 1),
(116, 'Singapour', 4608167, 686, 4, 16),
(117, 'Irlande', 4581269, 70282, 5, 3),
(118, 'République centrafricaine', 4511488, 622984, 6, 11),
(119, 'Croatie', 4456096, 56594, 5, 1),
(121, 'Palestine', 4289121, 6225, 4, 14),
(122, 'Costa Rica', 4195914, 51090, 1, 4),
(123, 'Liban', 4143101, 10452, 4, 14),
(124, 'Congo', 3847191, 341821, 6, 9),
(126, 'Libéria', 3786764, 111370, 6, 12),
(127, 'Moldavie', 3560430, 33845, 5, 1),
(128, 'Somaliland', 3500000, 137600, 6, 10),
(129, 'Uruguay', 3494382, 176215, 2, 7),
(130, 'Oman', 3418085, 309550, 4, 14),
(131, 'Mauritanie', 3364940, 1030700, 6, 12),
(132, 'Lituanie', 3349872, 65303, 5, 2),
(133, 'Panama', 3309679, 77082, 1, 4),
(134, 'Arménie', 3267945, 29743, 4, 32),
(135, 'Albanie', 3196095, 28748, 5, 1),
(136, 'Mongolie', 2799035, 1564116, 4, 20),
(138, 'Koweït', 2691158, 17818, 4, 14),
(139, 'Bhoutan', 2358810, 46673, 4, 24),
(140, 'Lettonie', 2248469, 64589, 5, 2),
(141, 'Namibie', 2108665, 825418, 6, 9),
(142, 'Slovénie', 2050289, 20273, 5, 1),
(143, 'Macédoine', 2049613, 25713, 5, 1),
(144, 'Botswana', 2029307, 581730, 6, 9),
(145, 'Lesotho', 1919552, 30355, 6, 9),
(146, 'Gambie', 1824158, 11295, 6, 12),
(147, 'Kosovo', 1733872, 10887, 5, 1),
(148, 'Qatar', 1699435, 11582, 4, 14),
(149, 'Guinée-Bissau', 1628603, 36125, 6, 12),
(150, 'Gabon', 1514993, 267667, 6, 9),
(151, 'Estonie', 1340021, 45228, 5, 2),
(154, 'Bahreïn', 1214705, 750, 4, 14),
(155, 'Timor oriental', 1131612, 14874, 4, 15),
(156, 'Swaziland', 1128814, 17365, 6, 9),
(157, 'Chypre', 1102677, 9251, 5, 1),
(159, 'Djibouti', 882844, 23200, 6, 10),
(161, 'Guyana', 772298, 215083, 2, 6),
(163, 'Guinée équatoriale', 650702, 28051, 6, 9),
(164, 'Monténégro', 634907, 13812, 5, 1),
(166, 'Macao', 567957, 29, 4, 18),
(167, 'Sahara occidental', 519415, 266000, 6, 12),
(168, 'Transnistrie', 518700, 4163, 5, 1),
(169, 'Suriname', 514407, 163821, 2, 6),
(170, 'Luxembourg', 510781, 2586, 5, 2),
(172, 'Malte', 406771, 316, 5, 1),
(175, 'Brunei', 395027, 5765, 4, 16),
(176, 'Maldives', 385925, 298, 4, 27),
(177, 'Belize', 338948, 22966, 1, 4),
(178, 'Islande', 318452, 103125, 5, 3),
(183, 'Guyane', 232223, 83846, 2, 6),
(200, 'Andorre', 85959, 468, 5, 3),
(202, 'Man', 75831, 572, 5, 3),
(210, 'Féroé', 47511, 1399, 5, 3),
(213, 'Monaco', 35352, 2, 5, 3),
(214, 'Liechtenstein', 35236, 160, 5, 1),
(215, 'Gibraltar', 29723, 7, 5, 3),
(216, 'Saint-Marin', 29615, 61, 5, 1),
(228, 'Malouines', 4446, 12173, 2, 6),
(233, 'Vatican', 800, 1, 5, 1),
(235, 'Sikkim', 607688, 7096, 4, 24),
(236, 'Mizoram', 1091014, 21081, 4, 24),
(237, 'Arunachal Pradesh', 1382611, 83743, 4, 24),
(238, 'Goa', 1457723, 3702, 4, 27),
(239, 'Nagaland', 1980602, 16579, 4, 24),
(240, 'Manipur', 2721756, 22347, 4, 24),
(241, 'Meghalaya', 2964007, 22720, 4, 25),
(242, 'Tripura', 3671032, 10492, 4, 24),
(243, 'Himachal Pradesh', 6856509, 55673, 4, 31),
(244, 'Uttarakhand', 10116752, 53566, 4, 31),
(245, 'Jammu-et-Cachemire', 12548926, 222236, 4, 31),
(246, 'Haryana', 25353081, 44212, 4, 30),
(247, 'Chattisgarh', 25540196, 135194, 4, 29),
(248, 'Punjab', 27704236, 50362, 4, 31),
(249, 'Assam', 31169272, 78550, 4, 25),
(250, 'Jharkhand', 32966238, 74677, 4, 26),
(251, 'Kerala', 33387677, 38863, 4, 27),
(252, 'Orissa', 41947358, 155820, 4, 28),
(253, 'Gujarat', 60383628, 196024, 4, 30),
(254, 'Karnataka', 61130704, 191791, 4, 27),
(255, 'Rajasthan', 68621012, 342269, 4, 30),
(256, 'Tamil Nadu', 72138958, 130058, 4, 27),
(257, 'Madhya Pradesh', 72597565, 308252, 4, 30),
(258, 'Andhra Pradesh', 84665533, 275045, 4, 28),
(259, 'Bengale-Occidental', 91347736, 88752, 4, 26),
(260, 'Bihar', 103804637, 99200, 4, 26),
(261, 'Maharashtra', 112372972, 307713, 4, 28),
(262, 'Uttar Pradesh', 199581477, 243286, 4, 29),
(263, 'Guangdong', 104303132, 177900, 4, 18),
(264, 'Shandong', 95793065, 156700, 4, 22),
(265, 'Henan', 94023567, 167000, 4, 23),
(266, 'Sichuan', 80418200, 480000, 4, 24),
(267, 'Jiangsu', 78659903, 100000, 4, 22),
(268, 'Hebei', 71854202, 187700, 4, 21),
(269, 'Hunan', 65683722, 210500, 4, 19),
(270, 'Anhui', 59500510, 139600, 4, 19),
(271, 'Hubei', 57237740, 187500, 4, 19),
(272, 'Zhejiang', 54426891, 101800, 4, 19),
(273, 'Guangxi', 46026629, 236000, 4, 17),
(274, 'Yunnan', 45966239, 394000, 4, 17),
(275, 'Jiangxi', 44567475, 169900, 4, 18),
(276, 'Liaoning', 43746323, 145900, 4, 21),
(277, 'Heilongjiang', 38312224, 460000, 4, 20),
(278, 'Shaanxi', 37327378, 206000, 4, 23),
(279, 'Fujian', 36894216, 121400, 4, 18),
(280, 'Shanxi', 35712111, 150000, 4, 21),
(281, 'Guizhou', 34746468, 176000, 4, 17),
(282, 'Chongqing', 28846170, 82300, 4, 23),
(283, 'Jilin', 27462297, 187400, 4, 13),
(284, 'Gansu', 25575254, 390000, 4, 23),
(285, 'Mongolie-Intérieure', 24706321, 1100000, 4, 20),
(286, 'Shanghai', 23019148, 6340, 4, 22),
(287, 'Xinjiang', 21813334, 1650000, 4, 24),
(288, 'Pékin', 19612368, 16808, 4, 21),
(289, 'Tianjin', 12938224, 11000, 4, 21),
(290, 'Hainan', 8671518, 34000, 4, 18),
(291, 'Ningxia', 6301350, 66000, 4, 23),
(292, 'Qinghai', 5626722, 720000, 4, 24),
(293, 'Tibet', 3002166, 1200000, 4, 24),
(294, 'Washington', 6724540, 184824, 1, 5),
(295, 'Oregon', 3831074, 255026, 1, 5),
(296, 'Californie', 37253956, 423970, 1, 4),
(297, 'Idaho', 1567582, 216632, 1, 4),
(298, 'Nevada', 2700551, 286351, 1, 4),
(299, 'Montana', 989415, 381156, 1, 5),
(300, 'Wyoming', 563626, 253338, 1, 4),
(301, 'Utah', 2763885, 220080, 1, 5),
(302, 'Arizona', 6392017, 295254, 1, 5),
(303, 'Colorado', 5029196, 269837, 1, 5),
(304, 'Nouveau Mexique', 2059179, 315194, 1, 4),
(305, 'Dakota du Nord', 672591, 183272, 1, 5),
(306, 'Dakota du Sud', 814180, 199905, 1, 5),
(307, 'Nebraska', 1826341, 200520, 1, 5),
(308, 'Kansas', 2853118, 213283, 1, 5),
(309, 'Oklahoma', 3751351, 181196, 1, 5),
(310, 'Texas', 25145561, 696241, 1, 4),
(311, 'Minnesota', 5303925, 225365, 1, 5),
(312, 'Iowa', 3046355, 145743, 1, 5),
(313, 'Missouri', 5988927, 180693, 1, 5),
(314, 'Arkansas', 2915918, 137732, 1, 5),
(315, 'Louisiane', 4533372, 134382, 1, 5),
(316, 'Wisconsin', 5686986, 169790, 1, 5),
(317, 'Illinois', 12830632, 149997, 1, 5),
(318, 'Mississippi', 2967297, 125546, 1, 5),
(319, 'Michigan', 9883640, 250941, 1, 5),
(320, 'Indiana', 6483802, 94321, 1, 5),
(321, 'Kentucky', 4339367, 104749, 1, 5),
(322, 'Tennessee', 6346105, 109247, 1, 5),
(323, 'Alabama', 4779736, 135765, 1, 5),
(324, 'Ohio', 11536504, 116096, 1, 5),
(325, 'Géorgie', 9687653, 154077, 1, 5),
(326, 'Floride', 18801310, 170451, 1, 5),
(327, 'New York', 8175133, 1214, 1, 5),
(328, 'Pennsylvanie', 12702379, 119283, 1, 5),
(329, 'Virginie', 8001024, 110862, 1, 5),
(330, 'Maine', 1328361, 86542, 1, 5),
(331, 'Washington DC', 601723, 177, 1, 5),
(332, 'Alaska', 710231, 1717854, 1, 5),
(333, 'New Hampshire', 1316470, 24239, 1, 5),
(334, 'Caroline du Nord', 9535483, 139509, 1, 5),
(335, 'Caroline du Sud', 4625364, 82965, 1, 5),
(336, 'Connecticut', 3574097, 14371, 1, 5),
(337, 'Delaware', 897934, 6452, 1, 5),
(338, 'Hawaï', 1360301, 28337, 1, 4),
(339, 'Maryland', 5573552, 32160, 1, 5),
(340, 'Massachusetts', 6547629, 27360, 1, 5),
(341, 'New Jersey', 8781894, 22608, 1, 5),
(342, 'Rhode Island', 1052567, 4002, 1, 5),
(343, 'Virginie Occidentale', 1852994, 62809, 1, 5),
(344, 'Vermont', 625741, 24823, 1, 5),
(345, 'Archipels de l''Amérique du Nord', 41819792, 2405700, 1, 4),
(346, 'Archipels de l''Afrique', 23911552, 599729, 6, 9),
(347, 'Archipels de l''Océanie', 13895338, 821594, 4, 15),
(349, 'Aceh', 4031589, 51937, 4, 16),
(350, 'Bali', 3383572, 5633, 4, 15),
(351, 'Banten', 9028816, 9018, 4, 16),
(352, 'Bengkulu', 1549273, 19795, 4, 16),
(353, 'Gorontalo', 922176, 12215, 4, 15),
(354, 'Iles Bangka Belitung', 1043456, 16171, 4, 16),
(355, 'Iles Riau', 1274848, 8084, 4, 16),
(356, 'Jakarta', 8860381, 664, 4, 16),
(357, 'Jambi', 2635968, 53437, 4, 16),
(358, 'Java central', 31977968, 32549, 4, 15),
(359, 'Java occidental', 38965440, 34597, 4, 16),
(360, 'Java oriental', 36294280, 47922, 4, 15),
(361, 'Kalimantan central', 1914900, 153564, 4, 16),
(362, 'Kalimantan du Sud', 3446631, 43546, 4, 16),
(363, 'Kalimantan occidental', 4052345, 153564, 4, 16),
(364, 'Kalimantan oriental', 2848798, 230277, 4, 16),
(365, 'Lampung', 7116177, 35384, 4, 16),
(366, 'Moluques', 1251539, 46975, 4, 15),
(367, 'Moluques du Nord', 884142, 30895, 4, 15),
(368, 'Papouasie', 1875388, 365466, 4, 15),
(369, 'Papouasie occidentale', 643012, 114566, 4, 15),
(370, 'Petites Îles de la Sonde occidenta', 4184411, 20153, 4, 15),
(371, 'Petites Îles de la Sonde orientale', 4260294, 47351, 4, 15),
(372, 'Riau', 4579219, 87844, 4, 16),
(373, 'Sulawesi central', 2294841, 63678, 4, 15),
(374, 'Sulawesi du Nord', 2128780, 15273, 4, 15),
(375, 'Sulawesi du Sud', 7509704, 62365, 4, 15),
(376, 'Sulawesi du Sud-Est', 1963025, 38140, 4, 15),
(377, 'Sulawesi occidental', 969429, 16787, 4, 15),
(378, 'Sumatra du Nord', 12450911, 73587, 4, 16),
(379, 'Sumatra du Sud', 6782339, 93083, 4, 16),
(380, 'Sumatra occidental', 4566126, 42899, 4, 16),
(381, 'Yogyakarta', 3343651, 3186, 4, 15);

--
-- Contraintes pour les tables exportées
--

--
-- Contraintes pour la table `ideo_evenement_effet`
--
ALTER TABLE `ideo_evenement_effet`
  ADD CONSTRAINT `ideo_evenement_effet_ibfk_2` FOREIGN KEY (`ee_jauge_id`) REFERENCES `ideo_jauge` (`jauge_id`),
  ADD CONSTRAINT `ideo_evenement_effet_ibfk_3` FOREIGN KEY (`ee_operation_id`) REFERENCES `ideo_evenement_operation` (`eo_id`);

--
-- Contraintes pour la table `ideo_jauge_caracteristique`
--
ALTER TABLE `ideo_jauge_caracteristique`
  ADD CONSTRAINT `ideo_jauge_caract_ibfk_1` FOREIGN KEY (`caract_jauge_id`) REFERENCES `ideo_jauge` (`jauge_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `ideo_jauge_caract_ibfk_2` FOREIGN KEY (`caract_ideo_id`) REFERENCES `ideo_ideologie` (`ideo_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `ideo_score`
--
ALTER TABLE `ideo_score`
  ADD CONSTRAINT `ideo_score_ibfk_1` FOREIGN KEY (`score_ideologie_id`) REFERENCES `ideo_ideologie` (`ideo_id`);

--
-- Contraintes pour la table `ideo_territoire_operation_cout`
--
ALTER TABLE `ideo_territoire_operation_cout`
  ADD CONSTRAINT `ideo_territoire_operation_cout_ibfk_2` FOREIGN KEY (`toc_ideologie_id`) REFERENCES `ideo_ideologie` (`ideo_id`),
  ADD CONSTRAINT `ideo_territoire_operation_cout_ibfk_4` FOREIGN KEY (`toc_operation_id`) REFERENCES `ideo_territoire_operation` (`to_id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `terr_unite`
--
ALTER TABLE `terr_unite`
  ADD CONSTRAINT `terr_unite_ibfk_1` FOREIGN KEY (`unite_continent`) REFERENCES `terr_continent` (`continent_id`),
  ADD CONSTRAINT `terr_unite_ibfk_2` FOREIGN KEY (`unite_territoire`) REFERENCES `terr_territoire` (`terr_id`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
