/*

Cleaning data in SQL 

*/


select *
from PortfolioProject.dbo.NashvilleHousing

------------------------------------------------------------------------------------

-- Standardize date format (using CONVERT)

select SaleDateConverted, CONVERT(Date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

Alter table NashvilleHousing
add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


----------------------------------------------------------------------------------------

-- Populate property address data (using ISNULL)

select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


Update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-----------------------------------------------------------------------------------------------------------
-- Breaking out (Splitting) address into individual columns (Address, City, State)

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing


select 
substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
, substring(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing


Alter table NashvilleHousing
add ProppertySplitAddress nvarchar(255);

Update NashvilleHousing
SET ProppertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

Alter table NashvilleHousing
add ProppertySplitCity nvarchar(255);

Update NashvilleHousing
SET ProppertySplitCity = substring(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))


select *
from PortfolioProject.dbo.NashvilleHousing


-- Another way of splitting the address into individual columns (Address, City, State) (using PARSENAME)

select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing


select
PARSENAME(Replace(OwnerAddress, ',', '.') , 3)
,PARSENAME(Replace(OwnerAddress, ',', '.') , 2)
,PARSENAME(Replace(OwnerAddress, ',', '.') , 1)
from PortfolioProject.dbo.NashvilleHousing



Alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.') , 3)

Alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.') , 2)

Alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.') , 1)



-------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field (using CASE statements)

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant
, case when SoldAsVacant = 'Y' Then 'Yes'
    when SoldAsVacant = 'N' Then 'No'
	else SoldAsVacant
	end
from PortfolioProject.dbo.NashvilleHousing


update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' Then 'Yes'
    when SoldAsVacant = 'N' Then 'No'
	else SoldAsVacant
	end

-------------------------------------------------------------------------------------------------------------------

-- Remove duplicates (using CTE, ROW_NUMBER, PARTITION BY)

With RowNumCTE as(
select *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
            PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			order by 
			  UniqueID
			  ) row_num

from PortfolioProject.dbo.NashvilleHousing

)
delete
from RowNumCTE
where row_num > 1


-----------------------------------------------------------------------------------------------------------------------------------

-- Delete unused columns

select*
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table PortfolioProject.dbo.NashvilleHousing
drop column SaleDate
