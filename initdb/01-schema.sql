-- Active: 1773398591614@@0.0.0.0@5437@postgres
CREATE TABLE personne (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(100),
    prenom VARCHAR(100),
    age INT,
    telephone VARCHAR(30),
    email VARCHAR(255)
);

CREATE TABLE technicien_profession (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE technicien (
    id SERIAL PRIMARY KEY,
    fk_personne INT,
    fk_technicien_profession INT,
    CONSTRAINT fk_technicien_personne
        FOREIGN KEY (fk_personne) REFERENCES personne(id),
    CONSTRAINT fk_technicien_profession
        FOREIGN KEY (fk_technicien_profession) REFERENCES technicien_profession(id)
);

CREATE TABLE type_intervention (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE intervention (
    id SERIAL PRIMARY KEY,
    date DATE,
    objet VARCHAR(255),
    fk_type_intervention INT,
    duree INT,
    cout_materiel DECIMAL(10,2),
    remarque TEXT,
    fk_personne INT,
    CONSTRAINT fk_intervention_type_intervention
        FOREIGN KEY (fk_type_intervention) REFERENCES type_intervention(id),
    CONSTRAINT fk_intervention_personne
        FOREIGN KEY (fk_personne) REFERENCES personne(id)
);

CREATE TABLE type_mobilier (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE materiaux_mobilier (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL
);

CREATE TABLE etat_mobilier (
    id INT PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE inventaire_mobilier (
    id SERIAL PRIMARY KEY,
    fk_type_mobilier INT,
    fk_materiaux_mobilier INT,
    lieu VARCHAR(255),
    latitude DECIMAL(10,7),
    longitude DECIMAL(10,7),
    date_installation DATE,
    fk_etat_mobilier INT,
    remarque TEXT,
    fk_personne INT,
    CONSTRAINT fk_inventaire_type_mobilier
        FOREIGN KEY (fk_type_mobilier) REFERENCES type_mobilier(id),
    CONSTRAINT fk_inventaire_materiaux_mobilier
        FOREIGN KEY (fk_materiaux_mobilier) REFERENCES materiaux_mobilier(id),
    CONSTRAINT fk_inventaire_etat_mobilier
        FOREIGN KEY (fk_etat_mobilier) REFERENCES etat_mobilier(id),
    CONSTRAINT fk_inventaire_personne
        FOREIGN KEY (fk_personne) REFERENCES personne(id)
);

CREATE TABLE statut_signalement (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE urgence_signalement (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE signalement (
    id SERIAL PRIMARY KEY,
    date DATE,
    fk_personne INT,
    objet VARCHAR(255),
    description TEXT,
    fk_urgence_signalement INT,
    fk_statut_signalement INT,
    CONSTRAINT fk_signalement_personne
        FOREIGN KEY (fk_personne) REFERENCES personne(id),
    CONSTRAINT fk_signalement_urgence
        FOREIGN KEY (fk_urgence_signalement) REFERENCES urgence_signalement(id),
    CONSTRAINT fk_signalement_statut
        FOREIGN KEY (fk_statut_signalement) REFERENCES statut_signalement(id)
);

CREATE TABLE intervention_signalement (
    id SERIAL PRIMARY KEY,
    fk_intervention INT,
    fk_signalement INT,
    CONSTRAINT fk_intervention_signalement_intervention
        FOREIGN KEY (fk_intervention) REFERENCES intervention(id),
    CONSTRAINT fk_intervention_signalement_signalement
        FOREIGN KEY (fk_signalement) REFERENCES signalement(id)
);

CREATE TABLE inventaire_mobilier_signalement (
    id SERIAL PRIMARY KEY,
    fk_inventaire_mobilier INT,
    fk_signalement INT,
    CONSTRAINT fk_inv_mob_signalement_inventaire
        FOREIGN KEY (fk_inventaire_mobilier) REFERENCES inventaire_mobilier(id),
    CONSTRAINT fk_inv_mob_signalement_signalement
        FOREIGN KEY (fk_signalement) REFERENCES signalement(id)
);

CREATE TABLE inventaire_mobilier_intervention (
    id SERIAL PRIMARY KEY,
    fk_inventaire_mobilier INT,
    fk_intervention INT,
    CONSTRAINT fk_inv_mob_intervention_inventaire
        FOREIGN KEY (fk_inventaire_mobilier) REFERENCES inventaire_mobilier(id),
    CONSTRAINT fk_inv_mob_intervention_intervention
        FOREIGN KEY (fk_intervention) REFERENCES intervention(id)
);

CREATE TABLE type_materiel (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE fournisseur (
    id SERIAL PRIMARY KEY,
    entreprise VARCHAR(255),
    fk_type_materiel INT,
    remarque TEXT,
    fk_personne INT,
    CONSTRAINT fk_fournisseur_type_materiel
        FOREIGN KEY (fk_type_materiel) REFERENCES type_materiel(id),
    CONSTRAINT fk_fournisseur_personne
        FOREIGN KEY (fk_personne) REFERENCES personne(id)
);