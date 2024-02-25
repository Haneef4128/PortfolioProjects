--Cleaning Data in SQL Queries

select * from PortfolioProject..NashvilleHousing
  
--Standardize Date Format

select SaleDateConverted, convert(date,saledate) 
from PortfolioProject..NashvilleHousing


alter table NashvilleHousing
add SaleDateConverted date

update NashvilleHousing set SaleDateConverted = convert(date,saledate) 

--Popularity Property Address data

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out address into individual columns(Address,City,State)

select 
substring(propertyaddress, 1, charindex(',', propertyaddress) -1) as Address,
substring(propertyaddress, charindex(',', propertyaddress) +1, len(propertyaddress)) as Address
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255)

update NashvilleHousing 
set PropertySplitAddress = substring(propertyaddress, 1, charindex(',', propertyaddress) -1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255)

update NashvilleHousing 
set PropertySplitCity = substring(propertyaddress, charindex(',', propertyaddress) +1, len(propertyaddress)) 

select * from PortfolioProject..NashvilleHousing

select OwnerAddress
from PortfolioProject..NashvilleHousing

select 
PARSENAME(replace(owneraddress,',','.'),3),
PARSENAME(replace(owneraddress,',','.'),2),
PARSENAME(replace(owneraddress,',','.'),1)
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255)

update NashvilleHousing 
set OwnerSplitAddress = PARSENAME(replace(owneraddress,',','.'),3) 

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255)

update NashvilleHousing 
set OwnerSplitCity = PARSENAME(replace(owneraddress,',','.'),2) 

alter table NashvilleHousing
add OwnerSplitState nvarchar(255)

update NashvilleHousing 
set OwnerSplitState = PARSENAME(replace(owneraddress,',','.'),1) 

--Change Y and N to Yes and No in "Sold as Vacant" field

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end 
 
select distinct(soldasvacant)
from PortfolioProject..NashvilleHousing

--Remove Duplicates

with RowNumCTE as(
select *,
	ROW_NUMBER() OVER(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by UniqueID) row_num
from PortfolioProject..NashvilleHousing)

select *
from RowNumCTE
where row_num>1

--Delete Unused columns

select * 
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
drop column owneraddress,taxdistrict,propertyaddress

alter table PortfolioProject..NashvilleHousing
drop column saledate