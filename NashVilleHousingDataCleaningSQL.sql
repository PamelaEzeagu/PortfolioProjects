--Cleaning Data with SQL Queries
	SELECT *
	FROM NashvilleHousing

	--Standardize the date format
	SELECT *, CONVERT (Date,SaleDate)
	FROM NashvilleHousing

	ALTER TABLE NashvilleHousing
	ADD SaleDate1 Date;

	UPDATE NashvilleHousing
	SET SaleDate1 = CONVERT (Date,SaleDate)


--Populating Property Address
	SELECT *
	FROM NashvilleHousing
	--where PropertyAddress is null
	order by parcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
WHERE a.propertyAddress is  null

UPDATE a
SET PropertyAddress =  ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]

--Seperating the Address into individual columns(Address,City,State)
SELECT PropertyAddress
FROM NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertyAddressSplit nvarchar(255);

UPDATE NashvilleHousing
SET PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertyCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD		OwnerAddressSplit nvarchar(255);

UPDATE NashvilleHousing
SET OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


--Changing Y and N in the SoldAsVacant Column to Yes and No
SELECT Distinct (SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
group by SoldAsVacant
order by 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
	   END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant= CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
	   END

--Remove Duplicates
WITH RownumCTE AS (
SELECT *,
 ROW_NUMBER() OVER (
 PARTITION BY ParcelID,
              PropertyAddress,
			  SalePrice,
			  SaleDate,
			  LegalReference
 ORDER BY UniqueID
           ) row_num
FROM NashvilleHousing
)
DELETE
FROM RownumCTE
WHERE row_num > 1
--Order by PropertyAddress

--Delete Unused Columns
ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate, PropertyAddress, OwnerAddress



