DROP VIEW IF EXISTS staging.v_inventaire_mobilier_nettoye;

CREATE VIEW staging.v_inventaire_mobilier_nettoye AS
WITH inventaire_nettoye AS (
    SELECT
        TRIM(id) AS id_brut,

        CASE
            WHEN LOWER(TRIM(type)) IN ('banc', 'banc public') THEN 'banc'
            WHEN LOWER(TRIM(type)) IN ('lampadaire', 'lampadaire sodium') THEN 'lampadaire'
            WHEN LOWER(TRIM(type)) = 'lampadaire led' THEN 'lampadaire_led'
            WHEN LOWER(TRIM(type)) IN ('poubelle', 'corbeille') THEN 'poubelle'
            WHEN LOWER(TRIM(type)) = 'poubelle tri' THEN 'poubelle_tri'
            WHEN LOWER(TRIM(type)) IN ('fontaine', 'fontaine publique') THEN 'fontaine'
            WHEN LOWER(TRIM(type)) IN ('borne ev', 'borne recharge', 'borne recharge ev') THEN 'borne_ev'
            WHEN LOWER(TRIM(type)) IN ('panneau', 'panneau info', 'panneau affichage') THEN 'panneau'
            ELSE LOWER(TRIM(type))
        END AS type_normalise,

        CASE
            WHEN LOWER(TRIM(materiau)) IN ('metal', 'métal') THEN 'métal'
            WHEN LOWER(TRIM(materiau)) = 'bois' THEN 'bois'
            WHEN LOWER(TRIM(materiau)) = 'pierre' THEN 'pierre'
            WHEN LOWER(TRIM(materiau)) = 'béton' THEN 'béton'
            WHEN LOWER(TRIM(materiau)) = 'led' THEN 'led'
            WHEN NULLIF(TRIM(materiau), '') IS NULL THEN NULL
            ELSE LOWER(TRIM(materiau))
        END AS materiau_normalise,

        INITCAP(LOWER(TRIM(lieu))) AS lieu_normalise,

        CASE
            WHEN NULLIF(TRIM(latitude), '') IS NULL THEN NULL
            WHEN TRIM(latitude) ~ '^-?[0-9]+([.,][0-9]+)?$'
                THEN REPLACE(TRIM(latitude), ',', '.')::NUMERIC(9,6)
            ELSE NULL
        END AS latitude,

        CASE
            WHEN NULLIF(TRIM(longitude), '') IS NULL THEN NULL
            WHEN TRIM(longitude) ~ '^-?[0-9]+([.,][0-9]+)?$'
                THEN REPLACE(TRIM(longitude), ',', '.')::NUMERIC(9,6)
            ELSE NULL
        END AS longitude,

        CASE
            WHEN date_installation ~ '^\d{2}\.\d{2}\.\d{4}$'
                THEN TO_DATE(date_installation, 'DD.MM.YYYY')
            WHEN date_installation ~ '^\d{4}-\d{2}-\d{2}$'
                THEN TO_DATE(date_installation, 'YYYY-MM-DD')
            WHEN date_installation ~ '^\d{4}$'
                THEN TO_DATE(date_installation || '-01-01', 'YYYY-MM-DD')
            WHEN LOWER(TRIM(date_installation)) LIKE 'janvier %'
                THEN TO_DATE('01.01.' || RIGHT(TRIM(date_installation), 4), 'DD.MM.YYYY')
            WHEN LOWER(TRIM(date_installation)) LIKE 'février %'
                THEN TO_DATE('01.02.' || RIGHT(TRIM(date_installation), 4), 'DD.MM.YYYY')
            WHEN LOWER(TRIM(date_installation)) LIKE 'mars %'
                THEN TO_DATE('01.03.' || RIGHT(TRIM(date_installation), 4), 'DD.MM.YYYY')
            WHEN LOWER(TRIM(date_installation)) LIKE 'avril %'
                THEN TO_DATE('01.04.' || RIGHT(TRIM(date_installation), 4), 'DD.MM.YYYY')
            WHEN LOWER(TRIM(date_installation)) LIKE 'mai %'
                THEN TO_DATE('01.05.' || RIGHT(TRIM(date_installation), 4), 'DD.MM.YYYY')
            WHEN LOWER(TRIM(date_installation)) LIKE 'juin %'
                THEN TO_DATE('01.06.' || RIGHT(TRIM(date_installation), 4), 'DD.MM.YYYY')
            WHEN LOWER(TRIM(date_installation)) LIKE 'juillet %'
                THEN TO_DATE('01.07.' || RIGHT(TRIM(date_installation), 4), 'DD.MM.YYYY')
            WHEN LOWER(TRIM(date_installation)) LIKE 'août %'
                THEN TO_DATE('01.08.' || RIGHT(TRIM(date_installation), 4), 'DD.MM.YYYY')
            WHEN LOWER(TRIM(date_installation)) LIKE 'septembre %'
                THEN TO_DATE('01.09.' || RIGHT(TRIM(date_installation), 4), 'DD.MM.YYYY')
            WHEN LOWER(TRIM(date_installation)) LIKE 'octobre %'
                THEN TO_DATE('01.10.' || RIGHT(TRIM(date_installation), 4), 'DD.MM.YYYY')
            WHEN LOWER(TRIM(date_installation)) LIKE 'novembre %'
                THEN TO_DATE('01.11.' || RIGHT(TRIM(date_installation), 4), 'DD.MM.YYYY')
            WHEN LOWER(TRIM(date_installation)) LIKE 'décembre %'
                THEN TO_DATE('01.12.' || RIGHT(TRIM(date_installation), 4), 'DD.MM.YYYY')
            WHEN TRIM(date_installation) ~ '^\d{5}$'
                THEN DATE '1899-12-30' + TRIM(date_installation)::INTEGER
            ELSE NULL
        END AS date_installation_normalisee,

        CASE
            WHEN LOWER(TRIM(etat)) IN ('bon', 'usé', 'à remplacer') THEN LOWER(TRIM(etat))
            ELSE NULL
        END AS etat_normalise,

        NULLIF(TRIM(remarques), '') AS remarques
    FROM staging.inventaire_mobilier
),
inventaire_dedoublonne AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY LOWER(TRIM(id_brut))
               ORDER BY id_brut
           ) AS rn
    FROM inventaire_nettoye
)
SELECT
    id_brut,
    type_normalise,
    materiau_normalise,
    lieu_normalise,
    latitude,
    longitude,
    date_installation_normalisee,
    etat_normalise,
    remarques
FROM inventaire_dedoublonne
WHERE rn = 1;

DROP VIEW IF EXISTS staging.v_fournisseurs_contacts_nettoyes;

CREATE VIEW staging.v_fournisseurs_contacts_nettoyes AS
SELECT
    INITCAP(TRIM(entreprise)) AS entreprise,

    NULLIF(TRIM(contact), '') AS contact,

    CASE
        WHEN telephone IS NULL THEN NULL
        WHEN TRIM(telephone) = '#ERROR!' THEN NULL
        ELSE NULLIF(REGEXP_REPLACE(telephone, '[^0-9+]', '', 'g'), '')
    END AS telephone_normalise,

    CASE
        WHEN email IS NULL THEN NULL
        WHEN NULLIF(TRIM(email), '') IS NULL THEN NULL
        WHEN LOWER(TRIM(email)) = 'voir site web' THEN NULL
        WHEN POSITION('@' IN email) > 1 THEN LOWER(TRIM(email))
        ELSE NULL
    END AS email_normalise,

    LOWER(TRIM(type_materiel)) AS type_materiel_normalise,

    NULLIF(TRIM(remarques), '') AS remarques,

    CASE
        WHEN LOWER(COALESCE(remarques, '')) LIKE '%fermé%' THEN FALSE
        ELSE TRUE
    END AS actif
FROM staging.fournisseurs_contacts;

DROP VIEW IF EXISTS staging.v_interventions_nettoyees;

CREATE VIEW staging.v_interventions_nettoyees AS
SELECT
    CASE
        WHEN date ~ '^\d{4}-\d{2}-\d{2}$'
            THEN TO_DATE(date, 'YYYY-MM-DD')
        WHEN date ~ '^\d{2}\.\d{2}\.\d{4}$'
            THEN TO_DATE(date, 'DD.MM.YYYY')
        ELSE NULL
    END AS date_intervention,

    INITCAP(LOWER(TRIM(objet))) AS objet,

    CASE
        WHEN LOWER(TRIM(type_intervention)) IN ('réparation', 'reparation') THEN 'réparation'
        WHEN LOWER(TRIM(type_intervention)) IN ('réparation électrique', 'reparation electrique') THEN 'réparation électrique'
        WHEN LOWER(TRIM(type_intervention)) = 'remplacement ampoule' THEN 'remplacement ampoule'
        WHEN LOWER(TRIM(type_intervention)) = 'remplacement complet' THEN 'remplacement complet'
        WHEN LOWER(TRIM(type_intervention)) = 'redressage mât' THEN 'redressage mât'
        WHEN LOWER(TRIM(type_intervention)) = 'nettoyage' THEN 'nettoyage'
        WHEN LOWER(TRIM(type_intervention)) = 'nettoyage tags' THEN 'nettoyage tags'
        WHEN LOWER(TRIM(type_intervention)) = 'peinture' THEN 'peinture'
        WHEN LOWER(TRIM(type_intervention)) = 'remplacement latte' THEN 'remplacement latte'
        WHEN LOWER(TRIM(type_intervention)) = 'remplacement couvercle' THEN 'remplacement couvercle'
        WHEN LOWER(TRIM(type_intervention)) = 'réparation fuite' THEN 'réparation fuite'
        WHEN LOWER(TRIM(type_intervention)) = 'remise en service' THEN 'remise en service'
        WHEN LOWER(TRIM(type_intervention)) = 'hivernage' THEN 'hivernage'
        WHEN LOWER(TRIM(type_intervention)) = 'détartrage' THEN 'détartrage'
        WHEN LOWER(TRIM(type_intervention)) = 'remplacement pompe' THEN 'remplacement pompe'
        WHEN LOWER(TRIM(type_intervention)) = 'mise à jour logiciel' THEN 'mise à jour logiciel'
        ELSE LOWER(TRIM(type_intervention))
    END AS type_intervention_normalise,

    CASE
        WHEN LOWER(TRIM(technicien)) IN ('jm', 'jean-marc', 'jean-marc bonvin')
            THEN 'Jean-Marc Bonvin'
        WHEN LOWER(TRIM(technicien)) IN ('pedro', 'alves pedro', 'p. alves')
            THEN 'Pedro Alves'
        WHEN LOWER(TRIM(technicien)) = 'koffi marc'
            THEN 'Koffi Marc'
        WHEN LOWER(TRIM(technicien)) = 'stagiaire'
            THEN 'Stagiaire'
        ELSE NULL
    END AS technicien_normalise,

    CASE
        WHEN LOWER(TRIM(duree)) = '30 min' THEN 30
        WHEN LOWER(TRIM(duree)) = '1h' THEN 60
        WHEN LOWER(TRIM(duree)) = '1h30' THEN 90
        WHEN LOWER(TRIM(duree)) = '2h' THEN 120
        WHEN LOWER(TRIM(duree)) = '3h' THEN 180
        WHEN LOWER(TRIM(duree)) = 'une matinée' THEN 240
        WHEN LOWER(TRIM(duree)) = 'une journée' THEN 480
        ELSE NULL
    END AS duree_minutes,

    CASE
        WHEN NULLIF(TRIM(cout_materiel), '') IS NULL THEN NULL
        WHEN LOWER(TRIM(cout_materiel)) IN ('garantie', 'gratuit') THEN 0
        ELSE NULLIF(REGEXP_REPLACE(cout_materiel, '[^0-9]', '', 'g'), '')::INTEGER
    END AS cout_materiel_chf,

    NULLIF(TRIM(remarques), '') AS remarques
FROM staging.interventions;

DROP VIEW IF EXISTS staging.v_signalements_nettoyes;

CREATE VIEW staging.v_signalements_nettoyes AS
SELECT
    CASE
        WHEN date ~ '^\d{4}-\d{2}-\d{2}$'
            THEN TO_DATE(date, 'YYYY-MM-DD')
        WHEN date ~ '^\d{2}\.\d{2}\.\d{4}$'
            THEN TO_DATE(date, 'DD.MM.YYYY')
        ELSE NULL
    END AS date_signalement,

    NULLIF(TRIM(signale_par), '') AS signale_par,

    INITCAP(LOWER(TRIM(objet))) AS objet,

    NULLIF(TRIM(description), '') AS description,

    CASE
        WHEN LOWER(TRIM(urgence)) = 'urgent' THEN 'urgent'
        WHEN LOWER(TRIM(urgence)) = 'normal' THEN 'normal'
        WHEN NULLIF(TRIM(urgence), '') IS NULL THEN 'normal'
        ELSE NULL
    END AS urgence_normalisee,

    CASE
        WHEN LOWER(TRIM(statut)) IN ('fait', 'en attente', 'en cours')
            THEN LOWER(TRIM(statut))
        WHEN NULLIF(TRIM(statut), '') IS NULL
            THEN 'nouveau'
        ELSE NULL
    END AS statut_normalise
FROM staging.signalements;


SELECT * FROM staging.v_inventaire_mobilier_nettoye LIMIT 20;
SELECT * FROM staging.v_fournisseurs_contacts_nettoyes LIMIT 20;
SELECT * FROM staging.v_interventions_nettoyees LIMIT 20;
SELECT * FROM staging.v_signalements_nettoyes LIMIT 20;


SELECT COUNT(*) FROM staging.inventaire_mobilier;
SELECT COUNT(*) FROM staging.v_inventaire_mobilier_nettoye;

SELECT COUNT(*) FROM staging.interventions;
SELECT COUNT(*) FROM staging.v_interventions_nettoyees;

SELECT COUNT(*) FROM staging.signalements;
SELECT COUNT(*) FROM staging.v_signalements_nettoyes;

SELECT COUNT(*) FROM staging.fournisseurs_contacts;
SELECT COUNT(*) FROM staging.v_fournisseurs_contacts_nettoyes;


SELECT LOWER(TRIM(id)) AS id_norm, COUNT(*)
FROM staging.inventaire_mobilier
GROUP BY LOWER(TRIM(id))
HAVING COUNT(*) > 1;

SELECT date_installation
FROM staging.inventaire_mobilier
WHERE date_installation IS NOT NULL
  AND TRIM(date_installation) <> ''
  AND date_installation NOT IN (
      SELECT TO_CHAR(date_installation_normalisee, 'YYYY-MM-DD')
      FROM staging.v_inventaire_mobilier_nettoye
      WHERE date_installation_normalisee IS NOT NULL
  );