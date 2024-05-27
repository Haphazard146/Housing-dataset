use portfolioprojects

-- Data cleaning

select * from Nashvillehousing

-- standardize date format

select SaleDate, convert(date,SaleDate)
from Nashvillehousing

alter table Nashvillehousing
alter column SaleDate date

--Populate property address data

select *
from nashvillehousing
where propertyaddress is null -- we get the data where propertyaddress is null

select a.parcelID, a.propertyaddress, b.parcelID, b.propertyaddress --isnull(a.propertyaddress,b.propertyaddress)
from nashvillehousing a
join nashvillehousing b
on a.parcelID = b.parcelID
and a.uniqueID <> b.uniqueID
where a. propertyaddress is null

update a
set propertyaddress = isnull(a.propertyaddress,b.propertyaddress)
from nashvillehousing a
join nashvillehousing b
on a.parcelID = b.parcelID
and a.uniqueID <> b.uniqueID
where a. propertyaddress is null

--breaking out address into individual columns

select propertyaddress from nashvillehousing
order by parcelID

select
substring(propertyaddress, 1, charindex(',', propertyaddress) -1) as address1,
substring(propertyaddress, charindex(',', propertyaddress) +1, len(propertyaddress)) as address2
from nashvillehousing

alter table nashvillehousing
add propertysplitaddress nvarchar(255);
update nashvillehousing
set propertysplitaddress = substring(propertyaddress, 1, charindex(',', propertyaddress) -1)

alter table nashvillehousing
add propertysplitcity nvarchar(255);
update nashvillehousing
set propertysplitcity = substring(propertyaddress, charindex(',', propertyaddress) +1, len(propertyaddress))

--Spliting owneraddress

select
parsename(replace(owneraddress,',','.'),3),
parsename(replace(owneraddress,',','.'),2), 
parsename(replace(owneraddress,',','.'),1)
from nashvillehousing
select*from nashvillehousing

alter table nashvillehousing
add ownersplitaddress nvarchar(255);
update nashvillehousing
set ownersplitaddress = parsename(replace(owneraddress,',','.'),3)

alter table nashvillehousing
add ownersplitcity nvarchar(255);
update nashvillehousing
set ownersplitcity = parsename(replace(owneraddress,',','.'),2)

alter table nashvillehousing
add ownersplitstate nvarchar(255);
update nashvillehousing
set ownersplitstate = parsename(replace(owneraddress,',','.'),1)

-- change Y and N to yes and no in "soldasvacant' column

select distinct(soldasvacant), count(soldasvacant)
from nashvillehousing
group by soldasvacant
order by 2

select soldasvacant from Nashvillehousing
, case when soldasvacant = 'Y' then 'Yes'
when soldasvacant = 'N' then 'No'
else soldasvacant
end from Nashvillehousing

update nashvillehousing
set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
when soldasvacant = 'N' then 'No'
else soldasvacant end

--remove duplicates

WITH ROWNUMCTE as(
select *,
    row_number() over (
	partition by parcelID,
	             propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 order by 
				    uniqueid
					) row_num
from nashvillehousing
--order by parcelId
)
DELETE from ROWNUMCTE
where row_num >1
--order by PropertyAddress

-- delete unused columns
-- since we have split propertyaddress and owneraddress they are of no use to us now, so we can delete those columns and also taxdistrict being the same
select*from Nashvillehousing

alter table nashvillehousing
drop column owneraddress, taxdistrict, propertyaddress
