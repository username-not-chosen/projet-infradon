-- Active: 1773398619980@@127.0.0.1@5437@service-bancs-yvedon
CREATE EXTENSION IF NOT EXISTS unaccent;


-- ============================================================
-- INVENTAIRE MOBILIER
-- ============================================================

SELECT DISTINCT public.unaccent(LOWER(TRIM("type")))
FROM staging.inventaire_mobilier
WHERE type IS NOT NULL;

SELECT
    id,
    type,
    materiau,
    etat,
    date_installation,
    CASE
        WHEN public.unaccent (LOWER(TRIM("type"))) LIKE '%banc%' THEN 'banc'
        WHEN public.unaccent (LOWER(TRIM("type"))) LIKE '%lampadaire%' THEN 'lampadaire'
        WHEN public.unaccent (LOWER(TRIM("type"))) LIKE '%poubelle%' THEN 'poubelle'
        WHEN public.unaccent (LOWER(TRIM("type"))) LIKE '%corbeille%' THEN 'poubelle'
        ELSE NULL
    END AS type_normalise,
    CASE
        WHEN public.unaccent (LOWER(TRIM(materiau))) LIKE '%metal%' THEN 'metal'
        WHEN public.unaccent (LOWER(TRIM(materiau))) LIKE '%bois%' THEN 'bois'
        WHEN public.unaccent (LOWER(TRIM(materiau))) LIKE '%sodium%' THEN 'sodium'
        WHEN public.unaccent (LOWER(TRIM(materiau))) LIKE '%beton%' THEN 'beton'
        WHEN public.unaccent (LOWER(TRIM(materiau))) LIKE '%pierre%' THEN 'pierre'
        WHEN public.unaccent (LOWER(TRIM(materiau))) LIKE '%led%' THEN 'led'
        ELSE NULL
    END AS materiau_normalise,
    CASE
        WHEN public.unaccent (LOWER(TRIM(etat))) LIKE '%remplacer%' THEN 'a remplacer'
        WHEN public.unaccent (LOWER(TRIM(etat))) LIKE '%bon%' THEN 'bon'
        WHEN public.unaccent (LOWER(TRIM(etat))) LIKE '%use%' THEN 'use'
        ELSE NULL
    END AS etat_normalise,
    CASE
        WHEN date_installation ~ '^\d{4}$' THEN TO_DATE(
            '01.01.' || date_installation,
            'DD.MM.YYYY'
        )
        WHEN date_installation ~ '^\d{2}\.\d{2}\.\d{4}$' THEN TO_DATE(
            date_installation,
            'DD.MM.YYYY'
        )
        WHEN date_installation ~ '^\d{4}-\d{2}-\d{2}$' THEN TO_DATE(
            date_installation,
            'YYYY-MM-DD'
        )
        WHEN date_installation ~ '^[a-zA-Zéèêëàâîïôöùûüç]+ \d{4}$' THEN TO_DATE(
            '01.' || CASE LOWER(
                    split_part(date_installation, ' ', 1)
                )
                WHEN 'janvier' THEN '01'
                WHEN 'fevrier' THEN '02'
                WHEN 'février' THEN '02'
                WHEN 'mars' THEN '03'
                WHEN 'avril' THEN '04'
                WHEN 'mai' THEN '05'
                WHEN 'juin' THEN '06'
                WHEN 'juillet' THEN '07'
                WHEN 'aout' THEN '08'
                WHEN 'août' THEN '08'
                WHEN 'septembre' THEN '09'
                WHEN 'octobre' THEN '10'
                WHEN 'novembre' THEN '11'
                WHEN 'decembre' THEN '12'
                WHEN 'décembre' THEN '12'
            END || '.' || split_part(date_installation, ' ', 2),
            'DD.MM.YYYY'
        )
        WHEN date_installation ~ '^\d{5}$' THEN DATE '1899-12-30' + date_installation::int
        ELSE NULL
    END AS date_installation_normalisee
FROM staging.inventaire_mobilier
WHERE
    type IS NOT NULL
    OR materiau IS NOT NULL;


-- ============================================================
-- INTERVENTIONS
-- ============================================================

SELECT DISTINCT public.unaccent(LOWER(TRIM(type_intervention)))
FROM staging.interventions
WHERE type_intervention IS NOT NULL;

SELECT DISTINCT public.unaccent(LOWER(TRIM(technicien)))
FROM staging.interventions
WHERE technicien IS NOT NULL;

SELECT DISTINCT public.unaccent(LOWER(TRIM(duree)))
FROM staging.interventions
WHERE duree IS NOT NULL;

SELECT DISTINCT public.unaccent(LOWER(TRIM(cout_materiel)))
FROM staging.interventions
WHERE cout_materiel IS NOT NULL;

SELECT
    date,
    objet,
    type_intervention,
    technicien,
    duree,
    cout_materiel,
    remarques,
    CASE
        WHEN date ~ '^\d{4}$' THEN TO_DATE(
            '01.01.' || date,
            'DD.MM.YYYY'
        )
        WHEN date ~ '^\d{2}\.\d{2}\.\d{4}$' THEN TO_DATE(
            date,
            'DD.MM.YYYY'
        )
        WHEN date ~ '^\d{4}-\d{2}-\d{2}$' THEN TO_DATE(
            date,
            'YYYY-MM-DD'
        )
        WHEN date ~ '^[a-zA-Zéèêëàâîïôöùûüç]+ \d{4}$' THEN TO_DATE(
            '01.' || CASE LOWER(
                    split_part(date, ' ', 1)
                )
                WHEN 'janvier' THEN '01'
                WHEN 'fevrier' THEN '02'
                WHEN 'février' THEN '02'
                WHEN 'mars' THEN '03'
                WHEN 'avril' THEN '04'
                WHEN 'mai' THEN '05'
                WHEN 'juin' THEN '06'
                WHEN 'juillet' THEN '07'
                WHEN 'aout' THEN '08'
                WHEN 'août' THEN '08'
                WHEN 'septembre' THEN '09'
                WHEN 'octobre' THEN '10'
                WHEN 'novembre' THEN '11'
                WHEN 'decembre' THEN '12'
                WHEN 'décembre' THEN '12'
            END || '.' || split_part(date, ' ', 2),
            'DD.MM.YYYY'
        )
        WHEN date ~ '^\d{5}$' THEN DATE '1899-12-30' + date::int
        ELSE NULL
    END AS date_normalisee,
    INITCAP(LOWER(TRIM(objet))) AS objet_normalise,
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
    NULLIF(TRIM(remarques), '') AS remarques_normalisees
FROM staging.interventions
WHERE
    date IS NOT NULL
    OR type_intervention IS NOT NULL;


-- ============================================================
-- FOURNISSEURS CONTACTS
-- ============================================================

SELECT DISTINCT public.unaccent(LOWER(TRIM(telephone)))
FROM staging.fournisseurs_contacts
WHERE telephone IS NOT NULL;

SELECT DISTINCT public.unaccent(LOWER(TRIM(email)))
FROM staging.fournisseurs_contacts
WHERE email IS NOT NULL;

SELECT DISTINCT LOWER(TRIM(type_materiel))
FROM staging.fournisseurs_contacts
WHERE type_materiel IS NOT NULL;

SELECT
    entreprise,
    contact,
    telephone,
    email,
    type_materiel,
    remarques,
    INITCAP(TRIM(entreprise)) AS entreprise_normalise,
    NULLIF(TRIM(contact), '') AS contact_normalise,
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
    NULLIF(TRIM(remarques), '') AS remarques_normalisees,
    CASE
        WHEN public.unaccent (LOWER(COALESCE(remarques, ''))) LIKE '%ferme%' THEN FALSE
        ELSE TRUE
    END AS actif
FROM staging.fournisseurs_contacts;


-- ============================================================
-- SIGNALEMENTS
-- ============================================================

SELECT DISTINCT LOWER(TRIM(urgence))
FROM staging.signalements
WHERE urgence IS NOT NULL;

SELECT DISTINCT LOWER(TRIM(statut))
FROM staging.signalements
WHERE statut IS NOT NULL;

SELECT
    date,
    signale_par,
    objet,
    description,
    urgence,
    statut,
    CASE
        WHEN date ~ '^\d{4}-\d{2}-\d{2}$' THEN TO_DATE(
            date,
            'YYYY-MM-DD'
        )
        WHEN date ~ '^\d{2}\.\d{2}\.\d{4}$' THEN TO_DATE(
            date,
            'DD.MM.YYYY'
        )
        ELSE NULL
    END AS date_normalisee,
    NULLIF(TRIM(signale_par), '') AS signale_par_normalise,
    INITCAP(LOWER(TRIM(objet))) AS objet_normalise,
    NULLIF(TRIM(description), '') AS description_normalisee,
    CASE
        WHEN LOWER(TRIM(urgence)) = 'urgent' THEN 'urgent'
        WHEN LOWER(TRIM(urgence)) = 'normal' THEN 'normal'
        WHEN NULLIF(TRIM(urgence), '') IS NULL THEN 'normal'
        ELSE NULL
    END AS urgence_normalisee,
    CASE
        WHEN LOWER(TRIM(statut)) = 'fait' THEN 'fait'
        WHEN LOWER(TRIM(statut)) = 'en attente' THEN 'en attente'
        WHEN LOWER(TRIM(statut)) = 'en cours' THEN 'en cours'
        WHEN NULLIF(TRIM(statut), '') IS NULL THEN 'nouveau'
        ELSE NULL
    END AS statut_normalise
FROM staging.signalements
WHERE
    date IS NOT NULL
    OR objet IS NOT NULL;


-- ============================================================
-- INSERT INTO PRODUCTION
-- (décommenter après validation des SELECT ci-dessus)
-- ============================================================

--- Étape 1 : référentiels ---

INSERT INTO type_mobilier (libelle)
SELECT DISTINCT
    CASE
        WHEN public.unaccent (LOWER(TRIM("type"))) LIKE '%banc%' THEN 'banc'
        WHEN public.unaccent (LOWER(TRIM("type"))) LIKE '%lampadaire%' THEN 'lampadaire'
        WHEN public.unaccent (LOWER(TRIM("type"))) LIKE '%poubelle%' THEN 'poubelle'
        WHEN public.unaccent (LOWER(TRIM("type"))) LIKE '%corbeille%' THEN 'poubelle'
        ELSE NULL
    END
FROM staging.inventaire_mobilier
WHERE type IS NOT NULL
    AND public.unaccent (LOWER(TRIM("type"))) LIKE ANY (ARRAY['%banc%', '%lampadaire%', '%poubelle%', '%corbeille%'])
ON CONFLICT (libelle) DO NOTHING;

INSERT INTO materiaux_mobilier (libelle)
SELECT DISTINCT
    CASE
        WHEN public.unaccent (LOWER(TRIM(materiau))) LIKE '%metal%' THEN 'metal'
        WHEN public.unaccent (LOWER(TRIM(materiau))) LIKE '%bois%' THEN 'bois'
        WHEN public.unaccent (LOWER(TRIM(materiau))) LIKE '%sodium%' THEN 'sodium'
        WHEN public.unaccent (LOWER(TRIM(materiau))) LIKE '%beton%' THEN 'beton'
        WHEN public.unaccent (LOWER(TRIM(materiau))) LIKE '%pierre%' THEN 'pierre'
        WHEN public.unaccent (LOWER(TRIM(materiau))) LIKE '%led%' THEN 'led'
        ELSE NULL
    END
FROM staging.inventaire_mobilier
WHERE materiau IS NOT NULL
    AND public.unaccent (LOWER(TRIM(materiau))) LIKE ANY (ARRAY['%metal%', '%bois%', '%sodium%', '%beton%', '%pierre%', '%led%'])
ON CONFLICT DO NOTHING;

INSERT INTO etat_mobilier (id, libelle) VALUES
    (1, 'bon'),
    (2, 'use'),
    (3, 'a remplacer')
ON CONFLICT (id) DO NOTHING;

INSERT INTO type_intervention (libelle)
SELECT DISTINCT
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
    END
FROM staging.interventions
WHERE type_intervention IS NOT NULL
ON CONFLICT (libelle) DO NOTHING;

INSERT INTO urgence_signalement (libelle) VALUES
    ('urgent'),
    ('normal')
ON CONFLICT (libelle) DO NOTHING;

INSERT INTO statut_signalement (libelle) VALUES
    ('nouveau'),
    ('en attente'),
    ('en cours'),
    ('fait')
ON CONFLICT (libelle) DO NOTHING;

INSERT INTO type_materiel (libelle)
SELECT DISTINCT LOWER(TRIM(type_materiel))
FROM staging.fournisseurs_contacts
WHERE type_materiel IS NOT NULL
ON CONFLICT (libelle) DO NOTHING;

--- Étape 2 : personnes ---

INSERT INTO personne (nom, prenom)
SELECT DISTINCT
    TRIM(SPLIT_PART(
        CASE
            WHEN LOWER(TRIM(technicien)) IN ('jm', 'jean-marc', 'jean-marc bonvin') THEN 'Jean-Marc Bonvin'
            WHEN LOWER(TRIM(technicien)) IN ('pedro', 'alves pedro', 'p. alves') THEN 'Pedro Alves'
            WHEN LOWER(TRIM(technicien)) = 'koffi marc' THEN 'Koffi Marc'
            WHEN LOWER(TRIM(technicien)) = 'stagiaire' THEN 'Stagiaire'
            ELSE NULL
        END
    , ' ', 2)) AS nom,
    TRIM(SPLIT_PART(
        CASE
            WHEN LOWER(TRIM(technicien)) IN ('jm', 'jean-marc', 'jean-marc bonvin') THEN 'Jean-Marc Bonvin'
            WHEN LOWER(TRIM(technicien)) IN ('pedro', 'alves pedro', 'p. alves') THEN 'Pedro Alves'
            WHEN LOWER(TRIM(technicien)) = 'koffi marc' THEN 'Koffi Marc'
            WHEN LOWER(TRIM(technicien)) = 'stagiaire' THEN 'Stagiaire'
            ELSE NULL
        END
    , ' ', 1)) AS prenom
FROM staging.interventions
WHERE technicien IS NOT NULL
    AND LOWER(TRIM(technicien)) IN ('jm', 'jean-marc', 'jean-marc bonvin', 'pedro', 'alves pedro', 'p. alves', 'koffi marc', 'stagiaire')
ON CONFLICT DO NOTHING;

INSERT INTO personne (nom, telephone, email)
SELECT DISTINCT
    NULLIF(TRIM(contact), ''),
    CASE
        WHEN telephone IS NULL THEN NULL
        WHEN TRIM(telephone) = '#ERROR!' THEN NULL
        ELSE NULLIF(REGEXP_REPLACE(telephone, '[^0-9+]', '', 'g'), '')
    END,
    CASE
        WHEN email IS NULL THEN NULL
        WHEN NULLIF(TRIM(email), '') IS NULL THEN NULL
        WHEN LOWER(TRIM(email)) = 'voir site web' THEN NULL
        WHEN POSITION('@' IN email) > 1 THEN LOWER(TRIM(email))
        ELSE NULL
    END
FROM staging.fournisseurs_contacts
WHERE contact IS NOT NULL
ON CONFLICT DO NOTHING;

--- Étape 3 : techniciens ---

INSERT INTO technicien_profession (libelle) VALUES
    ('technicien de voirie')
ON CONFLICT (libelle) DO NOTHING;

INSERT INTO technicien (fk_personne, fk_technicien_profession)
SELECT DISTINCT
    p.id,
    tp.id
FROM staging.interventions i
JOIN personne p
    ON p.prenom = TRIM(SPLIT_PART(
        CASE
            WHEN LOWER(TRIM(i.technicien)) IN ('jm', 'jean-marc', 'jean-marc bonvin') THEN 'Jean-Marc Bonvin'
            WHEN LOWER(TRIM(i.technicien)) IN ('pedro', 'alves pedro', 'p. alves') THEN 'Pedro Alves'
            WHEN LOWER(TRIM(i.technicien)) = 'koffi marc' THEN 'Koffi Marc'
            WHEN LOWER(TRIM(i.technicien)) = 'stagiaire' THEN 'Stagiaire'
            ELSE NULL
        END
    , ' ', 1))
    AND p.nom = TRIM(SPLIT_PART(
        CASE
            WHEN LOWER(TRIM(i.technicien)) IN ('jm', 'jean-marc', 'jean-marc bonvin') THEN 'Jean-Marc Bonvin'
            WHEN LOWER(TRIM(i.technicien)) IN ('pedro', 'alves pedro', 'p. alves') THEN 'Pedro Alves'
            WHEN LOWER(TRIM(i.technicien)) = 'koffi marc' THEN 'Koffi Marc'
            WHEN LOWER(TRIM(i.technicien)) = 'stagiaire' THEN 'Stagiaire'
            ELSE NULL
        END
    , ' ', 2))
JOIN technicien_profession tp ON tp.libelle = 'technicien de voirie'
WHERE i.technicien IS NOT NULL
ON CONFLICT DO NOTHING;

--- Étape 4 : inventaire mobilier ---

INSERT INTO inventaire_mobilier (
    fk_type_mobilier,
    fk_materiaux_mobilier,
    lieu,
    latitude,
    longitude,
    date_installation,
    fk_etat_mobilier,
    remarque
)
SELECT
    tm.id,
    mm.id,
    INITCAP(LOWER(TRIM(s.lieu))),
    CASE
        WHEN NULLIF(TRIM(s.latitude), '') IS NULL THEN NULL
        WHEN TRIM(s.latitude) ~ '^-?[0-9]+([.,][0-9]+)?$'
            THEN REPLACE(TRIM(s.latitude), ',', '.')::NUMERIC(9,6)
        ELSE NULL
    END,
    CASE
        WHEN NULLIF(TRIM(s.longitude), '') IS NULL THEN NULL
        WHEN TRIM(s.longitude) ~ '^-?[0-9]+([.,][0-9]+)?$'
            THEN REPLACE(TRIM(s.longitude), ',', '.')::NUMERIC(9,6)
        ELSE NULL
    END,
    CASE
        WHEN s.date_installation ~ '^\d{4}$'
            THEN TO_DATE('01.01.' || s.date_installation, 'DD.MM.YYYY')
        WHEN s.date_installation ~ '^\d{2}\.\d{2}\.\d{4}$'
            THEN TO_DATE(s.date_installation, 'DD.MM.YYYY')
        WHEN s.date_installation ~ '^\d{4}-\d{2}-\d{2}$'
            THEN TO_DATE(s.date_installation, 'YYYY-MM-DD')
        WHEN s.date_installation ~ '^[a-zA-Zéèêëàâîïôöùûüç]+ \d{4}$' THEN TO_DATE(
            '01.' || CASE LOWER(split_part(s.date_installation, ' ', 1))
                WHEN 'janvier' THEN '01' WHEN 'fevrier' THEN '02' WHEN 'février' THEN '02'
                WHEN 'mars' THEN '03' WHEN 'avril' THEN '04' WHEN 'mai' THEN '05'
                WHEN 'juin' THEN '06' WHEN 'juillet' THEN '07' WHEN 'aout' THEN '08'
                WHEN 'août' THEN '08' WHEN 'septembre' THEN '09' WHEN 'octobre' THEN '10'
                WHEN 'novembre' THEN '11' WHEN 'decembre' THEN '12' WHEN 'décembre' THEN '12'
            END || '.' || split_part(s.date_installation, ' ', 2), 'DD.MM.YYYY')
        WHEN s.date_installation ~ '^\d{5}$'
            THEN DATE '1899-12-30' + s.date_installation::int
        ELSE NULL
    END,
    em.id,
    NULLIF(TRIM(s.remarques), '')
FROM staging.inventaire_mobilier s
LEFT JOIN type_mobilier tm ON tm.libelle = CASE
    WHEN public.unaccent (LOWER(TRIM(s."type"))) LIKE '%banc%' THEN 'banc'
    WHEN public.unaccent (LOWER(TRIM(s."type"))) LIKE '%lampadaire%' THEN 'lampadaire'
    WHEN public.unaccent (LOWER(TRIM(s."type"))) LIKE '%poubelle%' THEN 'poubelle'
    WHEN public.unaccent (LOWER(TRIM(s."type"))) LIKE '%corbeille%' THEN 'poubelle'
    ELSE NULL END
LEFT JOIN materiaux_mobilier mm ON mm.libelle = CASE
    WHEN public.unaccent (LOWER(TRIM(s.materiau))) LIKE '%metal%' THEN 'metal'
    WHEN public.unaccent (LOWER(TRIM(s.materiau))) LIKE '%bois%' THEN 'bois'
    WHEN public.unaccent (LOWER(TRIM(s.materiau))) LIKE '%sodium%' THEN 'sodium'
    WHEN public.unaccent (LOWER(TRIM(s.materiau))) LIKE '%beton%' THEN 'beton'
    WHEN public.unaccent (LOWER(TRIM(s.materiau))) LIKE '%pierre%' THEN 'pierre'
    WHEN public.unaccent (LOWER(TRIM(s.materiau))) LIKE '%led%' THEN 'led'
    ELSE NULL END
LEFT JOIN etat_mobilier em ON em.libelle = CASE
    WHEN public.unaccent (LOWER(TRIM(s.etat))) LIKE '%remplacer%' THEN 'a remplacer'
    WHEN public.unaccent (LOWER(TRIM(s.etat))) LIKE '%bon%' THEN 'bon'
    WHEN public.unaccent (LOWER(TRIM(s.etat))) LIKE '%use%' THEN 'use'
    ELSE NULL END
WHERE s.type IS NOT NULL;

--- Étape 5 : interventions ---

INSERT INTO intervention (
    date,
    objet,
    fk_type_intervention,
    duree,
    cout_materiel,
    remarque,
    fk_personne
)
SELECT
    CASE
        WHEN date ~ '^\d{4}$' THEN TO_DATE('01.01.' || date, 'DD.MM.YYYY')
        WHEN date ~ '^\d{2}\.\d{2}\.\d{4}$' THEN TO_DATE(date, 'DD.MM.YYYY')
        WHEN date ~ '^\d{4}-\d{2}-\d{2}$' THEN TO_DATE(date, 'YYYY-MM-DD')
        WHEN date ~ '^[a-zA-Zéèêëàâîïôöùûüç]+ \d{4}$' THEN TO_DATE(
            '01.' || CASE LOWER(split_part(date, ' ', 1))
                WHEN 'janvier' THEN '01' WHEN 'fevrier' THEN '02' WHEN 'février' THEN '02'
                WHEN 'mars' THEN '03' WHEN 'avril' THEN '04' WHEN 'mai' THEN '05'
                WHEN 'juin' THEN '06' WHEN 'juillet' THEN '07' WHEN 'aout' THEN '08'
                WHEN 'août' THEN '08' WHEN 'septembre' THEN '09' WHEN 'octobre' THEN '10'
                WHEN 'novembre' THEN '11' WHEN 'decembre' THEN '12' WHEN 'décembre' THEN '12'
            END || '.' || split_part(date, ' ', 2), 'DD.MM.YYYY')
        WHEN date ~ '^\d{5}$' THEN DATE '1899-12-30' + date::int
        ELSE NULL
    END,
    INITCAP(LOWER(TRIM(objet))),
    ti.id,
    CASE
        WHEN LOWER(TRIM(duree)) = '30 min' THEN 30
        WHEN LOWER(TRIM(duree)) = '1h' THEN 60
        WHEN LOWER(TRIM(duree)) = '1h30' THEN 90
        WHEN LOWER(TRIM(duree)) = '2h' THEN 120
        WHEN LOWER(TRIM(duree)) = '3h' THEN 180
        WHEN LOWER(TRIM(duree)) = 'une matinée' THEN 240
        WHEN LOWER(TRIM(duree)) = 'une journée' THEN 480
        ELSE NULL
    END,
    CASE
        WHEN NULLIF(TRIM(cout_materiel), '') IS NULL THEN NULL
        WHEN LOWER(TRIM(cout_materiel)) IN ('garantie', 'gratuit') THEN 0
        ELSE NULLIF(REGEXP_REPLACE(cout_materiel, '[^0-9]', '', 'g'), '')::INTEGER
    END,
    NULLIF(TRIM(remarques), ''),
    p.id
FROM staging.interventions i
LEFT JOIN type_intervention ti ON ti.libelle = CASE
    WHEN LOWER(TRIM(i.type_intervention)) IN ('réparation', 'reparation') THEN 'réparation'
    WHEN LOWER(TRIM(i.type_intervention)) IN ('réparation électrique', 'reparation electrique') THEN 'réparation électrique'
    WHEN LOWER(TRIM(i.type_intervention)) = 'remplacement ampoule' THEN 'remplacement ampoule'
    WHEN LOWER(TRIM(i.type_intervention)) = 'remplacement complet' THEN 'remplacement complet'
    WHEN LOWER(TRIM(i.type_intervention)) = 'redressage mât' THEN 'redressage mât'
    WHEN LOWER(TRIM(i.type_intervention)) = 'nettoyage' THEN 'nettoyage'
    WHEN LOWER(TRIM(i.type_intervention)) = 'nettoyage tags' THEN 'nettoyage tags'
    WHEN LOWER(TRIM(i.type_intervention)) = 'peinture' THEN 'peinture'
    WHEN LOWER(TRIM(i.type_intervention)) = 'remplacement latte' THEN 'remplacement latte'
    WHEN LOWER(TRIM(i.type_intervention)) = 'remplacement couvercle' THEN 'remplacement couvercle'
    WHEN LOWER(TRIM(i.type_intervention)) = 'réparation fuite' THEN 'réparation fuite'
    WHEN LOWER(TRIM(i.type_intervention)) = 'remise en service' THEN 'remise en service'
    WHEN LOWER(TRIM(i.type_intervention)) = 'hivernage' THEN 'hivernage'
    WHEN LOWER(TRIM(i.type_intervention)) = 'détartrage' THEN 'détartrage'
    WHEN LOWER(TRIM(i.type_intervention)) = 'remplacement pompe' THEN 'remplacement pompe'
    WHEN LOWER(TRIM(i.type_intervention)) = 'mise à jour logiciel' THEN 'mise à jour logiciel'
    ELSE LOWER(TRIM(i.type_intervention)) END
LEFT JOIN personne p
    ON p.prenom = TRIM(SPLIT_PART(
        CASE
            WHEN LOWER(TRIM(i.technicien)) IN ('jm', 'jean-marc', 'jean-marc bonvin') THEN 'Jean-Marc Bonvin'
            WHEN LOWER(TRIM(i.technicien)) IN ('pedro', 'alves pedro', 'p. alves') THEN 'Pedro Alves'
            WHEN LOWER(TRIM(i.technicien)) = 'koffi marc' THEN 'Koffi Marc'
            WHEN LOWER(TRIM(i.technicien)) = 'stagiaire' THEN 'Stagiaire'
            ELSE NULL
        END
    , ' ', 1))
    AND p.nom = TRIM(SPLIT_PART(
        CASE
            WHEN LOWER(TRIM(i.technicien)) IN ('jm', 'jean-marc', 'jean-marc bonvin') THEN 'Jean-Marc Bonvin'
            WHEN LOWER(TRIM(i.technicien)) IN ('pedro', 'alves pedro', 'p. alves') THEN 'Pedro Alves'
            WHEN LOWER(TRIM(i.technicien)) = 'koffi marc' THEN 'Koffi Marc'
            WHEN LOWER(TRIM(i.technicien)) = 'stagiaire' THEN 'Stagiaire'
            ELSE NULL
        END
    , ' ', 2))
WHERE i.date IS NOT NULL;

--- Étape 6 : fournisseurs ---

INSERT INTO fournisseur (
    entreprise,
    fk_type_materiel,
    remarque,
    fk_personne
)
SELECT
    INITCAP(TRIM(f.entreprise)),
    tm.id,
    NULLIF(TRIM(f.remarques), ''),
    p.id
FROM staging.fournisseurs_contacts f
LEFT JOIN type_materiel tm
    ON tm.libelle = LOWER(TRIM(f.type_materiel))
LEFT JOIN personne p
    ON p.nom = NULLIF(TRIM(f.contact), '')
WHERE f.entreprise IS NOT NULL;

--- Étape 7 : signalements ---

INSERT INTO signalement (
    date,
    objet,
    description,
    fk_urgence_signalement,
    fk_statut_signalement
)
SELECT
    CASE
        WHEN date ~ '^\d{4}-\d{2}-\d{2}$' THEN TO_DATE(date, 'YYYY-MM-DD')
        WHEN date ~ '^\d{2}\.\d{2}\.\d{4}$' THEN TO_DATE(date, 'DD.MM.YYYY')
        ELSE NULL
    END,
    INITCAP(LOWER(TRIM(objet))),
    NULLIF(TRIM(description), ''),
    u.id,
    s.id
FROM staging.signalements sg
LEFT JOIN urgence_signalement u ON u.libelle = CASE
    WHEN LOWER(TRIM(sg.urgence)) = 'urgent' THEN 'urgent'
    WHEN LOWER(TRIM(sg.urgence)) = 'normal' THEN 'normal'
    WHEN NULLIF(TRIM(sg.urgence), '') IS NULL THEN 'normal'
    ELSE NULL END
LEFT JOIN statut_signalement s ON s.libelle = CASE
    WHEN LOWER(TRIM(sg.statut)) = 'fait' THEN 'fait'
    WHEN LOWER(TRIM(sg.statut)) = 'en attente' THEN 'en attente'
    WHEN LOWER(TRIM(sg.statut)) = 'en cours' THEN 'en cours'
    WHEN NULLIF(TRIM(sg.statut), '') IS NULL THEN 'nouveau'
    ELSE NULL END
WHERE sg.date IS NOT NULL;


-- ============================================================
-- VÉRIFICATIONS FINALES
-- ============================================================

SELECT COUNT(*) FROM staging.inventaire_mobilier;
SELECT COUNT(*) FROM inventaire_mobilier;    -- ~120

SELECT COUNT(*) FROM staging.interventions;
SELECT COUNT(*) FROM intervention;           -- ~150

SELECT COUNT(*) FROM staging.fournisseurs_contacts;
SELECT COUNT(*) FROM fournisseur;            -- ~14

SELECT COUNT(*) FROM staging.signalements;
SELECT COUNT(*) FROM signalement;            -- ~200