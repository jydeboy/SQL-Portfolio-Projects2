--CLEANING DATA IN SQL QUERIES

select * from Nashville_Housing

--STANDARDIZE DATE FORMAT

Select SaleDateConverted
from Nashville_Housing

Select SaleDate, Convert(Date,SaleDate)
From Nashville_Housing

Alter Table Nashville_Housing
Add SaleDateConverted Date;

Update Nashville_Housing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--POPULATE PROPERTY ADDRESS DATA

Select *
From Nashville_Housing
--where PropertyAddress is null
order by ParcelID

Select NH.ParcelID, NH.PropertyAddress, NH2.ParcelID, NH2.PropertyAddress, isnull(NH.PropertyAddress,NH2.PropertyAddress)
From Nashville_Housing NH
JOin Nashville_Housing NH2
on NH.ParcelID = NH2.ParcelID
And NH.[UniqueID ] <> NH2.[UniqueID ]
where NH.PropertyAddress is null

Update NH
SET PropertyAddress = isnull(NH.PropertyAddress,NH2.PropertyAddress)
From Nashville_Housing NH
JOin Nashville_Housing NH2
on NH.ParcelID = NH2.ParcelID
And NH.[UniqueID ] <> NH2.[UniqueID ]

--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMN (ADDRESS, CITY, STATE)

Select PropertyAddress
From Nashville_Housing

Select
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
, Substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , Len(PropertyAddress)) AS Address
From Nashville_Housing

Alter Table Nashville_Housing
Add PropertySplitAddress Nvarchar(255);


Update Nashville_Housing
SET PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 )

Alter Table Nashville_Housing
Add PropertySplitCity nvarchar(255);

Update Nashville_Housing
SET PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , Len(PropertyAddress)) 

select 
PARSENAME(Replace(OwnerAddress, ',', '.') , 3)
,PARSENAME(Replace(OwnerAddress, ',', '.') , 2)
,PARSENAME(Replace(OwnerAddress, ',', '.') , 1)
from Nashville_Housing

Alter Table Nashville_Housing
Add OwnerSplitAddress Nvarchar(255);

Update Nashville_Housing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.') , 3)

Alter Table Nashville_Housing
Add OwnerSplitCity nvarchar(255);

Update Nashville_Housing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.') , 2) 

Alter Table Nashville_Housing
Add OwnerSplitState nvarchar(255);

--CHANGE Y AND N TO YES AND NO IN 'SOLD AS VACANT' FIELD

Select SoldAsVacant,
Case when SoldAsVacant = 'Y' then 'Yes'
	 When SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End
From Nashville_Housing

Update Nashville_Housing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	 When SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Nashville_Housing
Group By SoldAsVacant
Order by 2

--REMOVING DUPLICATES 
With RowNumCTE AS(
Select *,
Row_Number() Over (
Partition By ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
Order By UniqueID) row_num
from Nashville_Housing
)
Select * 
From RowNumCTE
where Row_Num >1
Order By PropertyAddress

With RowNumCTE AS(
Select *,
Row_Number() Over (
Partition By ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
Order By UniqueID) row_num
from Nashville_Housing
)
Delete 
From RowNumCTE
where Row_Num >1

--DELETE UNUSED COLUMNS

Select * from Nashville_Housing

Alter Table Nashville_Housing
Drop Column OwnerAddress, TaxDistrict, SaleDate, PropertyAddress

