PRAGMA foreign_keys = ON;

-- Bölümler
CREATE TABLE IF NOT EXISTS Bolumler (
    bolum_id INTEGER PRIMARY KEY,
    bolum_adi TEXT NOT NULL
);

-- Dersler
CREATE TABLE IF NOT EXISTS Dersler (
    ders_id INTEGER PRIMARY KEY,
    ders_adi TEXT NOT NULL,
    bolum_id INTEGER NOT NULL,
    FOREIGN KEY (bolum_id) REFERENCES Bolumler(bolum_id) -- Ders hangi bölümde
);

-- Öğrenciler
CREATE TABLE IF NOT EXISTS Ogrenciler (
    ogrenci_id INTEGER PRIMARY KEY,
    ogrenci_no TEXT NOT NULL UNIQUE,
    ogrenci_adi TEXT NOT NULL,
    ogrenci_soyadi TEXT NOT NULL,
    bolum_id INTEGER NOT NULL,
    FOREIGN KEY (bolum_id) REFERENCES Bolumler(bolum_id) -- Öğrenci hang bölümde 
);

-- Öğrenci Ders İlişkisi

CREATE TABLE IF NOT EXISTS OgrenciDers (
    ogrenci_id INTEGER NOT NULL,
    ders_id INTEGER NOT NULL,
    PRIMARY KEY (ogrenci_id, ders_id), --İkisini irincil anahtar yapmamızın sebebi aynı öğrencinin aynı derse kaydolmasını engellemke.
    FOREIGN KEY (ogrenci_id) REFERENCES Ogrenciler(ogrenci_id),
    FOREIGN KEY (ders_id) REFERENCES Dersler(ders_id)
);

INSERT INTO Bolumler (bolum_adi) VALUES
('Bilgisayar Mühendisliği'),
('Elektrik-Elektronik Mühendisliği'),
('Yazılım Mühendisliği');

INSERT INTO Dersler (ders_adi, bolum_id) VALUES
('Veritabanı Sistemleri', 1),
('Algoritmalar ve Veri Yapıları', 1),
('Elektrik Devreleri', 2),
('Mikrodenetleyiciler', 2),
('Yazılım Mühendisliği Prensipleri', 3);

INSERT INTO Ogrenciler (ogrenci_no, ogrenci_adi, ogrenci_soyadi, bolum_id) VALUES
('OGER001', 'Abdullah', 'Belli', 1),
('OGER002', 'Elif', 'Demir', 1),
('OGER003', 'Zehra', 'Yalçın', 2),
('OGER004', 'Abdullah', 'Belli', 2),
('OGER005', 'Furkan', 'Yılmaz', 3);

INSERT INTO OgrenciDers (ogrenci_id, ders_id) VALUES
(1, 1),
(1, 2),
(2, 1),
(3, 3),
(4, 4),
(5, 5);

SELECT
    O.ogrenci_adi,
    O.ogrenci_soyadi,
    B.bolum_adi,
    D.ders_adi
FROM Ogrenciler O
INNER JOIN Bolumler B
    ON O.bolum_id = B.bolum_id
INNER JOIN OgrenciDers OD
    ON O.ogrenci_id = OD.ogrenci_id
INNER JOIN Dersler D
    ON OD.ders_id = D.ders_id;
