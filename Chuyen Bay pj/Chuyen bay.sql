use HangKhong
-- thong tin chuyen bay di Da Lat
select * from CHUYENBAY
where(GaDen = 'DAD')
-- tam bay lon hon 10000km
select * from MAYBAY
where (TamBay > 10000)
-- nhan vien co luong nho hon 10000
select * from NHANVIEN
where (Luong < 10000)
-- do dai duong bay < 10000km va > 8000km
select * from CHUYENBAY
where (DoDai > 8000 and DoDai < 10000)
-- xuat phat tu Sai Gon den Buon Me Thuot
select * from CHUYENBAY
where (GaDi = 'SGN' and GaDen = 'BMV')
-- bao nhieu chuyen bay xuat phat tu SG
select count(GaDI) from CHUYENBAY
where GaDi = 'SGN'
-- bao nhieu loai Boeing
select count(Hieu) from MayBay
where Hieu like 'Boeing %'
-- tong so luong phai tra cho nv
select sum(Luong) from NHANVIEN
-- ma va ten phi cong lai Boeing
select distinct nv.MaNV, nv.Ten from (( NHANVIEN as nv inner join CHUNGNHAN as cn on nv.MaNV = cn.MaNV) inner join MAYBAY as mb on cn.MaMB = mb.MaMB and mb.Hieu like 'Boeing %')
-- ma va ten phi cong lai may bay ma 747
select nv.MaNV, nv.Ten
from (( NHANVIEN as nv inner join CHUNGNHAN as cn on nv.MaNV = cn.MaNV) inner join MAYBAY as mb on cn.MaMB = mb.MaMB and mb.MaMB = '747')
-- ma so may bay co phi cong ho Nguyen
select cn.MaMB from CHUNGNHAN as cn, NHANVIEN as nv
where cn.MaNV = nv.MaNV and nv.Ten like 'Nguyen %'  
-- ma phi cong vua lai Boeing va Airbus A320
select cn.MaNV
from CHUNGNHAN as cn, MAYBAY as mb
where (cn.MaMB = mb.MaMB) and (mb.Hieu = 'Airbus A320')
intersect
select cn.MaNV
from CHUNGNHAN as cn, MAYBAY as mb
where (cn.MaMB = mb.MaMB) and (mb.Hieu like 'Boeing %')
-- cac loai may bay thu hien chuyen bay Vn280
select Hieu from MAYBAY, CHUYENBAY AS cb
where cb.MaCB = 'VN280'
-- cac chuyen bay thuc hien boi airbus a320
select * from CHUYENBAY, MAYBAY as mb
where mb.Hieu = 'Airbus A320'
-- ten phi cong lai boeing
select Ten from NHANVIEN as nv, MAYBAY as mb, CHUNGNHAN as cn
where (cn.MaNV = nv.MaNV) and (cn.MaMB = mb.MaMB) and (mb.Hieu like 'Boeing %')
-- Với mỗi loại máy bay có phi công lái, cho biết mã số, loại máy bay và tổng số phi công có thể lái loại máy bay đó
select  count(MaNV) as 'So nv', mb.Hieu
from MAYBAY as mb, CHUNGNHAN as cn
where cn.MaMB = mb.MaMB
group by mb.Hieu
-- Giả sử một hành khách muốn đi thẳng từ ga A đến ga B rồi quay trở về ga A. Cho biết các đường bay nào có thể đáp ứng yêu cầu này.
select GaDi, GaDen 
from CHUYENBAY
intersect 
select GaDen, GaDi
from CHUYENBAY
--Với mỗi ga có chuyến bay xuất phát từ đó, cho biết có bao nhiêu chuyến bay khởi hành
select GaDi, count(GaDi)
from CHUYENBAY
group by GaDi
-- Voi moi chuyen bay xuat phat tu do, tong chi phi tra phi cong
select GaDi, sum(ChiPhi)
from CHUYENBAY
group by GaDi
-- Voi moi chuyen bay xuat phat tu do, bao nhieu chuyen bay khoi hanh truoc 12:00
select GaDi, count(GaDi)
from CHUYENBAY
where GioDi < '12:00'
group by GaDi
-- ma so phi cong chi lai duoc 3 may bay
select MaNV, count(MaMB)
from CHUNGNHAN
group by MaNV
having count(MaMB) = 3
-- moi phi cong lai nhieu hon 3 may bay, cho biet ma phi cong va tam bay lon nhat cua may bay phi cong lai
select MaNV, count(cn.MaMB), max(TamBay)
from CHUNGNHAN as cn inner join MAYBAY as mb on cn.MaMB = mb.MaMB
group by MaNV
having count(cn.MaMB) > 3
-- ma so cua phi cong lai nhieu may bay nhat
select MaNV
from CHUNGNHAN 
group by MaNV
having COUNT(MaMB) >= all (select count(MaMB) from CHUNGNHAN group by MaNV)
-- ma so phi cong lai it may bay nhat
select MaNV
from CHUNGNHAN 
group by MaNV
having COUNT(MaMB) <= all (select count(MaMB) from CHUNGNHAN group by MaNV)
-- tim cac nhan vien khong phai phi cong
select MaNV
from NHANVIEN
except
select distinct MaNV
from CHUNGNHAN 
-- cho biet ma so nhan vien co luong cao nhat
select MaNV
from NHANVIEN
where Luong >= all (select max(Luong) from NHANVIEN group by MaNV)
group by MaNV
-- tong so luong tra cho phi cong
select sum(Luong) 'Total'
from NHANVIEN
where MaNV in (select MaNV from CHUNGNHAN intersect select MaNV from NHANVIEN)
-- cac chuyen bay thuc hien boi may bay boeing
select MaCB
from CHUYENBAY as cb, MAYBAY as mb
where  cb.DoDai < (select min(TamBay)
from MAYBAY
where Hieu like 'Boeing %')
group by MaCB
-- ma so may bay co the thuc hien chuyen bay tu Sai Gon den Hue
select MaMB 
from MAYBAY, CHUYENBAY
where GaDi = 'SGN' and GaDen = 'HUI' and TamBay > DoDai
-- tim cac chuyen bay duoc lai boi phi cong co luong lon hon 100000
select MaCB 
from CHUYENBAY
where  DoDai <= all (select mb.TamBay
from ((CHUNGNHAN as cn inner join NHANVIEN as nv on cn.MaNV = nv.MaNV) inner join MAYBAY as mb on cn.MaMB = mb.MaMB)
where nv.Luong > 100000
group by TamBay)
-- ten phi cong co luong nho hon chi phi thap nhat cua duong bay tu Sai Gon den Buon Ma Thuot 
select Ten
from NHANVIEN
where Luong < (select min(ChiPhi) from CHUYENBAY where GaDi = 'SGN' and GaDen = 'BMV')
group by Ten
-- ma so phi cong co luong cao nhat
select cn.MaNV
from NHANVIEN as nv inner join CHUNGNHAN as cn on nv.MaNV = cn.MaNV
group by cn.MaNV
having max(Luong) >= all (select max(Luong) from NHANVIEN as nv inner join CHUNGNHAN as cn on nv.MaNV = cn.MaNV group by Luong)
-- ma so nhan vien luong cao nhi
select MaNV
from NHANVIEN
where Luong >= all (select Luong from NHANVIEN where Luong < (select max(Luong) from NHANVIEN))
and Luong != (select max(Luong) from NHANVIEN)
-- ma so cua cac phi cong co luong cao nhat hoac cao nhi
select cn.MaNV
from NHANVIEN as nv inner join CHUNGNHAN as cn on nv.MaNV = cn.MaNV
where Luong >= all (select Luong from NHANVIEN as nv inner join CHUNGNHAN as cn on nv.MaNV = cn.MaNV where Luong < (select max(Luong) from NHANVIEN as nv inner join CHUNGNHAN as cn on nv.MaNV = cn.MaNV))
and Luong != (select max(Luong) from NHANVIEN as nv inner join CHUNGNHAN as cn on nv.MaNV = cn.MaNV) or Luong >= all (select max(Luong) from NHANVIEN as nv inner join CHUNGNHAN as cn on nv.MaNV = cn.MaNV group by Luong)
group by cn.MaNV
-- ten va luong cua nhan vien khong phai phi cong va lon hon luong trung binh cua phi cong
select Ten, Luong
from NHANVIEN
where MaNV not in (select MaNV from CHUNGNHAN) and Luong > (select avg(Luong) from NHANVIEN as nv inner join CHUNGNHAN as cn on nv.MaNV = cn.MaNV)
group by Ten, Luong
-- ten phi cong lai may bay co tam bay > 4800km nhung khong phai Boeing
select Ten
from (NHANVIEN as nv inner join CHUNGNHAN as cn on nv.MaNV = cn.MaNV) inner join MAYBAY as mb on mb.MaMB = cn.MaMB
where TamBay > 4800 and cn.MaNV not in (select MaNV from CHUNGNHAN as cn inner join MAYBAY as mb on cn.MaMB = mb.MaMB where Hieu like 'Boeing %')
group by Ten
-- ten phi cong lai it nhat 3 may bay co tam lai > 3200km
select Ten, count(cn.MaMB)
from (NHANVIEN as nv inner join CHUNGNHAN as cn on nv.MaNV = cn.MaNV) inner join MAYBAY as mb on mb.MaMB = cn.MaMB
where mb.TamBay > 3200
group by Ten
having count(cn.MaMB) >= 3
-- voi moi nhan vien cho viet ma, ten va so may bay lai duoc
select  count(cn.MaMB), Ten, cn.MaNV
from (NHANVIEN as nv inner join CHUNGNHAN as cn on nv.MaNV = cn.MaNV) inner join MAYBAY as mb on mb.MaMB = cn.MaMB
group by Ten, cn.MaNV
-- voi moi nhan vien cho viet ma, ten va so may bay Boeing lai duoc
select  count(cn.MaMB), Ten, cn.MaNV
from (NHANVIEN as nv inner join CHUNGNHAN as cn on nv.MaNV = cn.MaNV) inner join MAYBAY as mb on mb.MaMB = cn.MaMB
where Hieu like 'Boeing %'
group by Ten, cn.MaNV
-- voi moi loai may bay, cho biet loai va tong so phi cong lai duoc
select Hieu, count(cn.MaNV)
from MAYBAY as mb inner join CHUNGNHAN as cn on mb.MaMB = cn.MaMB
group by Hieu
-- voi moi loai may bay, cho biet loai va tong so chuyen bay khong the thuc hien
select Hieu, count(MaCB) as 'CB'
from MAYBAY, CHUYENBAY
where TamBay < DoDai
group by Hieu
-- voi moi loai may bay, cho biet loai va tong so phi cong co luong > 100000 lai duoc
select Hieu, count(cn.MaNV)
from (NHANVIEN as nv inner join CHUNGNHAN as cn on nv.MaNV = cn.MaNV) inner join MAYBAY as mb on mb.MaMB = cn.MaMB
where Luong > 100000
group by Hieu
-- voi moi loai may bay co tam bay tren 3200km, cho biet hieu va luong trung binh cua phi cong lai no
select Hieu, avg(Luong)
from (NHANVIEN as nv inner join CHUNGNHAN as cn on nv.MaNV = cn.MaNV) inner join MAYBAY as mb on mb.MaMB = cn.MaMB
where TamBay > 3200
group by Hieu
-- voi moi loai may bay, cho biet loai va tong so nhan vien khong the lai no
select c.Hieu, (select count(MaNV) from NHANVIEN) - count(b.MaNV) from NHANVIEN as a, CHUNGNHAN as b, MAYBAY as c 
where a.MaNV = b.MaNV and b.MaMB = c.MaMB
group by c.Hieu
-- voi moi loai may bay,  cho biet loai va tong so phi cong khong lai duoc
select c.Hieu, (select count(distinct MaNV) from CHUNGNHAN) - count(b.MaNV)
from NHANVIEN as a, CHUNGNHAN as b, MAYBAY as c 
where a.MaNV = b.MaNV and b.MaMB = c.MaMB 
group by c.Hieu
-- voi moi nhan vien, cho biet ma, ten nhan vien va tong so chuyen bay xuat phat tu Sai Gon ma nhan vien do khong the lai
select cn.MaNV, Ten, (select count(MaCB) from CHUYENBAY where GaDi = 'SGN') - count(distinct MaCB)
from CHUYENBAY, (NHANVIEN as nv inner join CHUNGNHAN as cn on nv.MaNV = cn.MaNV) inner join MAYBAY as mb on mb.MaMB = cn.MaMB
where GaDi = 'SGN' and TamBay > DoDai
group by cn.MaNV, Ten
-- voi moi phi cong, cho biet ma, ten phi cong va tong so chuyen bay tu Sai Gon ma phi cong co the lai
select cn.MaNV, Ten, count(distinct MaCB)
from CHUYENBAY, (NHANVIEN as nv inner join CHUNGNHAN as cn on nv.MaNV = cn.MaNV) inner join MAYBAY as mb on mb.MaMB = cn.MaMB
where GaDi = 'SGN' and TamBay > DoDai
group by cn.MaNV, Ten
-- voi moi chuyen bay cho biet ma va tong so loai may bay thuc hien duoc
select MaCB, count(Hieu)
from CHUYENBAY, MAYBAY
where TamBay > DoDai
group by MaCB
-- voi moi chuyen bay cho biet ma va tong so phi cong khong lai duoc
select MaCB, count(cn.MaNV)
from CHUYENBAY, (NHANVIEN as nv inner join CHUNGNHAN as cn on nv.MaNV = cn.MaNV) inner join MAYBAY as mb on mb.MaMB = cn.MaMB
where Tambay < DoDai
group by MaCB, cn.MaNV
-- mot hanh khach muon di tu Ha Noi den Nha Trang ma khong phai doi chuyen bay qua 1 lan. Cho biet ma, thoi gian khoi hanh tu Ha Noi neu muon den Nha Trang truoc 16:00
select MaCB, GioDi
from CHUYENBAY
where GioDen < '16:00' and (GaDi = 'HAN' and GaDen = 'CXR')
group by MaCB, GioDi
-- cho biet duong bay ma phi cong bay co luong tren 100000
select MaCB
from CHUYENBAY, (NHANVIEN as nv join CHUNGNHAN as cn on nv.MaNV = cn.MaNV) join MAYBAY as mb on mb.MaMB = cn.MaMB
where Luong > 100000 and TamBay > DoDai 
group by MaCB
except 
select MaCB
from CHUYENBAY, (NHANVIEN as nv join CHUNGNHAN as cn on nv.MaNV = cn.MaNV) join MAYBAY as mb on mb.MaMB = cn.MaMB
where Luong < 100000 and TamBay > DoDai 
group by MaCB
-- ten phi cong lai cac may bay co tam bay > 3200km va 1 trong so do là Boeing
select Ten
from (NHANVIEN as nv join CHUNGNHAN as cn on nv.MaNV = cn.MaNV) join MAYBAY as mb on mb.MaMB = cn.MaMB
where TamBay > 3200
group by Ten
intersect
select Ten
from (NHANVIEN as nv join CHUNGNHAN as cn on nv.MaNV = cn.MaNV) join MAYBAY as mb on mb.MaMB = cn.MaMB
where Hieu like 'Boeing %'
group by Ten
-- tim phi cong lai duoc tat ca may bay Boeing
select cn.MaNV
from CHUNGNHAN as cn join MAYBAY as mb on cn.MaMB = mb.MaMB
where Hieu like 'Boeing %'
group by cn.MaNV
having  Count(cn.MaMB) >= all  (select count(MaMB) from MAYBAY where Hieu like 'Boeing %')