PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS dersler (
    id INTEGER PRIMARY KEY,
    ders_adi TEXT
);

CREATE TABLE IF NOT EXISTS ogrenci_notlari (
    id INTEGER PRIMARY KEY,
    ogrenci_adi TEXT,
    ders_id INTEGER,
    ogrenciNotu INTEGER,
    FOREIGN KEY (ders_id) REFERENCES dersler(id)
);

INSERT INTO dersler (ders_adi) VALUES
('Matematik'),
('Fizik'),
('Kimya');

INSERT INTO ogrenci_notlari (ogrenci_adi, ders_id, not) VALUES
('Ahmet', 1, 80),
('Ahmet', 2, 70),
('Ayşe', 1, 90),
('Ayşe', 3, 85),
('Mehmet', 1, 95),
('Mehmet', 2, 75),
('Zeynep', 1, 65),
('Zeynep', 3, 75);

SELECT
    O.ogrenci_adi,
    D.ders_adi,
    O.ogrenciNotu
FROM ogrenci_notlari O
INNER JOIN dersler D
    ON O.ders_id = D.id;
    
SELECT
    ogrenci_adi,
    SUM(ogrenciNotu) AS toplam_not
FROM ogrenci_notlari
GROUP BY ogrenci_adi
ORDER BY toplam_not DESC;