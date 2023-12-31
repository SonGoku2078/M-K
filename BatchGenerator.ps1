# BatchGenerator.ps1

# Import the Excel data
$dataArray = Import-Excel -Path "$PSScriptRoot\Batch_Szenarios.xlsx" -WorksheetName 'Batch_Szenarios' | Where-Object { $_.StartCollateralETH -ne $null }

# Loop through each row of data
foreach ($data in $dataArray) {

    # Map variables from Excel data
    $StartCollateralETH         = $data.StartCollateralETH
    $ParBänder                  = $data.ParBänder
    $ParVaultSafetyUSD          = $data.ParVaultSafetyUSD
    $ParSaftyPriceDistancePct   = $data.ParSaftyPriceDistancePct
    $ParleverageEfficiency      = $data.ParleverageEfficiency
    $StartPrice                 = $data.StartPrice
    $ParPriceVariant            = $data.ParPriceVariant
    $ParFuturePricesInit        = @($data.StartPrice) # Adjust if necessary
    $ParOraclePriceIncreasePct  = $data.ParOraclePriceIncreasePct
    $ParOraclePriceIncreaseAbs  = $data.ParOraclePriceIncreaseAbs
    $ParOraclePriceLimit        = $data.ParOraclePriceLimit
    $ParKey                     = 'StColl='    + [string]$StartCollateralETH         +'|'+ `
                                  '_Bd='       + [string]$ParBänder                  +'|'+ `
                                  '_VSaf='     + [string]$ParVaultSafetyUSD          +'|'+ `
                                  '_SafPrcD='  + [string]$ParSaftyPriceDistancePct   +'|'+ `
                                  '_LevEff='   + [string]$ParleverageEfficiency      +'|'+ `
                                  '_PrcVar='   + [string]$ParPriceVariant            +'|'+ `
                                  '_FutPrc='   + [string]$ParFuturePricesInit        +'|'+ `
                                  '_OrcInPct'  + [string]$ParOraclePriceIncreasePct  +'|'+ `
                                  '_OrcInAbs'  + [string]$ParOraclePriceIncreaseAbs  +'|'+ `
                                  '_OrcPrcLim' + [string]$ParOraclePriceLimit        +'|'+ `
                                  '_StaPrc='   + [string]$StartPrice
         

    # CurveUSD_SALAMI.ps1 Script with the defined parameters
    .\CurveUSD_SALAMI.ps1 `
    -StartCollateralETH_Ext         $StartCollateralETH `
    -ParBänder_Ext                  $ParBänder `
    -ParVaultSafetyUSD_Ext          $ParVaultSafetyUSD `
    -ParSaftyPriceDistancePct_Ext   $ParSaftyPriceDistancePct `
    -ParleverageEfficiency_Ext      $ParleverageEfficiency `
    -StartPrice_Ext                 $StartPrice `
    -ParPriceVariant_Ext            $ParPriceVariant `
    -ParFuturePricesInit_Ext        $ParFuturePricesInit `
    -ParOraclePriceIncreasePct_Ext  $ParOraclePriceIncreasePct `
    -ParOraclePriceLimit_Ext        $ParOraclePriceLimit `
    -ParOraclePriceIncreaseAbs_Ext  $ParOraclePriceIncreaseAbs `
    -ParKey_Ext                     $ParKey
}

<#
    # Parameter definieren
    $StartCollateralETH         = 5
    $ParBänder                  = 4
    $ParVaultSafetyUSD          = 10.0      # 10% Sicherheit 
    $ParSaftyPriceDistancePct   = 25.0       
    $ParleverageEfficiency      = 5.0   # % change of previous (Old)CollateralETH based on leverage (TotCollateral)
    $StartPrice                 = 1863.34
    $ParPriceVariant            = "inc"       #fix | pct | inc
    $ParFuturePricesInit        = @($StartPrice) #, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000)        
    $ParOraclePriceIncreasePct  = 50  # "pct" $StartPrice will be taken and the number of %   
    $ParOraclePriceIncreaseAbs  = 500 # "inc" OraclePrice will increase by absolut number eg: every 500 usd of price increase
    $ParOraclePriceLimit        = 2000 # Limit is needed for for "inc" and "pct" 
    #>
    