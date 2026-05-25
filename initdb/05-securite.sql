
-- Création des rôles

CREATE ROLE citoyen;
CREATE ROLE technicien;
CREATE ROLE administrateur;

-- Rôle citoyen

GRANT SELECT ON inventaire_mobilier TO citoyen;
GRANT SELECT ON type_mobilier TO citoyen;
GRANT SELECT ON materiaux_mobilier TO citoyen;
GRANT SELECT ON etat_mobilier TO citoyen;
GRANT SELECT ON signalement TO citoyen;
GRANT SELECT ON urgence_signalement TO citoyen;
GRANT SELECT ON statut_signalement TO citoyen;


-- Rôle technicien

GRANT SELECT, INSERT, UPDATE ON inventaire_mobilier TO technicien;
GRANT SELECT, INSERT, UPDATE ON intervention TO technicien;
GRANT SELECT, INSERT, UPDATE ON signalement TO technicien;
GRANT SELECT, INSERT, UPDATE ON inventaire_mobilier_intervention TO technicien;
GRANT SELECT, INSERT, UPDATE ON inventaire_mobilier_signalement TO technicien;
GRANT SELECT, INSERT, UPDATE ON intervention_signalement TO technicien;
GRANT SELECT, INSERT, UPDATE ON personne TO technicien;

GRANT SELECT ON type_mobilier TO technicien;
GRANT SELECT ON materiaux_mobilier TO technicien;
GRANT SELECT ON etat_mobilier TO technicien;
GRANT SELECT ON type_intervention TO technicien;
GRANT SELECT ON urgence_signalement TO technicien;
GRANT SELECT ON statut_signalement TO technicien;
GRANT SELECT ON technicien_profession TO technicien;


-- Rôle administrateur

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO administrateur;


-- Users et attribution des rôles

CREATE USER marie WITH PASSWORD 'motdepasse' NOSUPERUSER NOCREATEDB;
CREATE USER jean_marc WITH PASSWORD 'motdepasse' NOSUPERUSER NOCREATEDB;
CREATE USER responsable WITH PASSWORD 'motdepasse' NOSUPERUSER NOCREATEDB;

GRANT citoyen TO marie;
GRANT technicien TO jean_marc;
GRANT administrateur TO responsable;