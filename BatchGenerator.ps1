# BatchGenerator.ps1
   
# Parameter definieren
$StartCollateralETH = 5
$ParBänder = 4

$ParVaultSafetyUSD = 10.0      # 10% Sicherheit 

$ParSaftyPriceDistancePct = 25.0       
$ParSaftyPriceDistanceDecimal = (100 - $ParSaftyPriceDistancePct) / 100

$ParleverageEfficiency = 5.0   # % change of previous (Old)CollateralETH based on leverage (TotCollateral)

$StartPrice = 1863.34
$ParPriceVariant = "inc"       #fix | pct | inc

$ParFuturePricesInit = @($StartPrice) #, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000)        

# "pct" $StartPrice will be taken and the number of % 
$ParOraclePriceIncreasePct = 50
$ParOraclePriceLimit = 10000

$ParOraclePriceIncreaseAbs = 500
$ParOraclePriceLimit2 = 2000   # Da es zweimal eine Variable namens $ParOraclePriceLimit gab, wurde der Name für die zweite Instanz geändert.

# CurveUSD_SALAMI.ps1 Skript mit den definierten Parametern aufrufen
.\CurveUSD_SALAMI.ps1 `
-StartCollateralETH_Ext $StartCollateralETH `
-ParBänder_Ext $ParBänder `
-ParVaultSafetyUSD_Ext $ParVaultSafetyUSD `
-ParSaftyPriceDistancePct_Ext $ParSaftyPriceDistancePct `
-ParSaftyPriceDistanceDecimal_Ext $ParSaftyPriceDistanceDecimal `
-ParleverageEfficiency_Ext $ParleverageEfficiency `
-StartPrice_Ext $StartPrice `
-ParPriceVariant_Ext $ParPriceVariant `
-ParFuturePricesInit_Ext $ParFuturePricesInit `
-ParOraclePriceIncreasePct_Ext $ParOraclePriceIncreasePct `
-ParOraclePriceLimit_Ext $ParOraclePriceLimit `
-ParOraclePriceIncreaseAbs_Ext $ParOraclePriceIncreaseAbs `
-ParOraclePriceLimit2_Ext $ParOraclePriceLimit2
