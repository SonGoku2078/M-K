﻿param(
    [int]$StartCollateralETH_Ext,
    [int]$ParBänder_Ext,
    [double]$ParVaultSafetyUSD_Ext,
    [double]$ParSaftyPriceDistancePct_Ext,
    [double]$ParleverageEfficiency_Ext,
    [double]$StartPrice_Ext,
    [string]$ParPriceVariant_Ext,
    [string]$ParMode_Ext,
    [double[]]$ParFuturePricesInit_Ext,
    [double]$ParOraclePriceIncreasePct_Ext,
    [double]$ParOraclePriceLimit_Ext,
    [double]$ParOraclePriceIncreaseAbs_Ext,
    [string]$ParKey_Ext
)


# ------------------------------------------
# Preparation
# ------------------------------------------
$OldcollateralETH   = 0
$OldCollateralUSD   = 0
$TotCollateralUSD   = 0
$NewCreditUSD       = 0
$NewKeet10pctUSD    = 0
$TotKeet10pctUSD    = 0
$NewCollateralETH   = 0
$TotCreditUSD       = 0
$TotCollateralETH   = 0
$TotCollateralUSD   = 0
$Leverage           = 0
$CollLoanRatio      = 0
$LoanCollRatio      = 0

function FuncMode{
    param (
        [string]$Variable,
        [string]$ValueText,
        [double]$ValueNumb,
        [array]$ValueArray        
    )
    $result = $null

    #StartCollateralETH
    if ($Variable -eq 'StartCollateralETH'){
        if ($Mode -eq "local") {$result = $ValueNumb} else {$result = $StartCollateralETH_Ext}
    }

    # ParBänder
    if ($Variable -eq 'ParBänder'){
        if ($Mode -eq "local") {$result = $ValueNumb} else {$result = $ParBänder_Ext}
    }

    # ParVaultSafetyUSD
    if ($Variable -eq 'ParVaultSafetyUSD'){
        if ($Mode -eq "local") {$result = $ValueNumb} else {$result = $ParVaultSafetyUSD_Ext}
    }

    # ParSaftyPriceDistancePct
    if ($Variable -eq 'ParSaftyPriceDistancePct'){
        if ($Mode -eq "local") {$result = $ValueNumb} else {$result = $ParSaftyPriceDistancePct_Ext}
    }

    # ParleverageEfficiency
    if ($Variable -eq 'ParleverageEfficiency'){
        if ($Mode -eq "local") {$result = $ValueNumb} else {$result = $ParleverageEfficiency_Ext}
    }

    # StartPrice
    if ($Variable -eq 'StartPrice'){
        if ($Mode -eq "local") {$result = $ValueNumb} else {$result = $StartPrice_Ext}
    }

    # ParPriceVariant
    if ($Variable -eq 'ParPriceVariant'){
        if ($Mode -eq "local") {$result = $ValueText} else {$result = $ParPriceVariant_Ext}
    }

    # ParFuturePricesInit
    if ($Variable -eq 'ParFuturePricesInit'){
        if ($Mode -eq "local") {$result = $ValueArray} else {$result = $ParFuturePricesInit_Ext}
    }

    # ParOraclePriceIncreasePct
    if ($Variable -eq 'ParOraclePriceIncreasePct'){
        if ($Mode -eq "local") {$result = $ValueNumb} else {$result = $ParOraclePriceIncreasePct_Ext}
    }

    # ParOraclePriceLimit
    if ($Variable -eq 'ParOraclePriceLimit'){
        if ($Mode -eq "local") {$result = $ValueNumb} else {$result = $ParOraclePriceLimit_Ext}
    }

    # ParOraclePriceIncreaseAbs
    if ($Variable -eq 'ParOraclePriceIncreaseAbs'){
        if ($Mode -eq "local") {$result = $ValueNumb} else {$result = $ParOraclePriceIncreaseAbs_Ext}
    }

    # ParOraclePriceLimit
    if ($Variable -eq 'ParOraclePriceLimit'){
        if ($Mode -eq "local") {$result = $ValueNumb} else {$result = $ParOraclePriceLimit_Ext}
    }

    Return $result
}

#-----------------------------------------------------------
# Settings
#-----------------------------------------------------------
# Lokal Settings
# $OutputFilePath                 = "C:\Users\SonGoku78\Downloads\"
$OutputFilePath                 = $PSScriptRoot
$Suffix                         = "Batch_Preis_Ansteig"     # Last part of the csv Filename

$TestVaultSafetyUSD             = 'N'
$TestSaftyPriceDistance         = 'N'
$TestLeverageEfficiency         = 'N'
$TestSoftLiquidPriceRange       = 'N'

# $ParKey      = $ParKey_Ext
# $Global:Mode = $ParMode_Ext
$Global:Mode = 'local'

$StartCollateralETH             = FuncMode -Variable 'StartCollateralETH'        -ValueNumb 5        
$ParBänder                      = FuncMode -Variable 'ParBänder'                 -ValueNumb 4       

#                                 z.B. 10% Sicherheit 
$ParVaultSafetyUSD              = FuncMode -Variable 'ParVaultSafetyUSD'         -ValueNumb 10.0    

#                                 % gap to oracle price eg. 25% = 0.75 + OraclePrice    
$ParSaftyPriceDistancePct       = FuncMode -Variable 'ParSaftyPriceDistancePct'  -ValueNumb 30.0    
$ParSaftyPriceDistanceDecimal   = (100 - $ParSaftyPriceDistancePct    ) / 100

#                                 % change of previous (Old)CollateralETH based on leverage (TotCollateral)                                    
$ParleverageEfficiency          = FuncMode -Variable 'ParleverageEfficiency'     -ValueNumb 5.0     

$StartPrice                     = FuncMode -Variable 'StartPrice'                -ValueNumb 1863.34 

#                                 fix=fix values | pct=percentage | inc=incremental 
$ParPriceVariant                = FuncMode -Variable 'ParPriceVariant'           -ValueText 'inc'   

#"fix"
$ParFuturePricesInit            = FuncMode -Variable 'ParPriceVariant'           -ValueArray @(($StartPrice), 2000, 3000)#, 4000, 5000, 6000, 7000, 8000, 9000, 10000)       

#"pct"                           OraclePrice will increase by % number eg: every 20% of price increase
$ParOraclePriceIncreasePct      = FuncMode -Variable 'ParOraclePriceIncreasePct' -ValueNumb 50     

$ParOraclePriceLimit            = FuncMode -Variable 'ParOraclePriceLimit'       -ValueNumb 10000     

#"inc"                            OraclePrice will increase by absolut number eg: every 500 usd of price increase
$ParOraclePriceIncreaseAbs      = FuncMode -Variable 'ParOraclePriceIncreaseAbs' -ValueNumb 500 
$ParOraclePriceLimit            = FuncMode -Variable 'ParOraclePriceLimit'       -ValueNumb 15000     



#-------------------------------------------------------
# Statistics & prints
#-------------------------------------------------------
$tableCalc=@()
$Global:tableCalc=@()
# print: variables & calculation
$tableCalc += [PSCustomObject]@{Calculation = "#--------------------------------------------------------------------------------------------------"}
$tableCalc += [PSCustomObject]@{Calculation = "# Calculations / Formulas"}
$tableCalc += [PSCustomObject]@{Calculation = "#--------------------------------------------------------------------------------------------------"}
$tableCalc += [PSCustomObject]@{Calculation = "# OldCollateralUSD   = OldcollateralETH     *   oracleprice[i1]"     }
$tableCalc += [PSCustomObject]@{Calculation = "# TotCollateralUSD   = TotCollateralETH     *   oracleprice[i1] "}
$tableCalc += [PSCustomObject]@{Calculation = "# NewCreditUSD       = TotCollateralUSD     -   TotCreditUSD)        *  MaxUsdMinting"    }
$tableCalc += [PSCustomObject]@{Calculation = "# NewKeet10pctUSD    = NewCreditUSD         *   (VaultSafetyUSD      /  100) # 10% Sicherheit"}
$tableCalc += [PSCustomObject]@{Calculation = "# TotKeet10pctUSD    = TotKeet10pctUSD      +   NewKeet10pctUSD  "}
$tableCalc += [PSCustomObject]@{Calculation = "# NewCollateralETH   = (NewCreditUSD        -   NewKeet10pctUSD)     /  oracleprice[i1]"}
$tableCalc += [PSCustomObject]@{Calculation = "# TotCreditUSD       = TotCreditUSD         +   NewCreditUSD"}
$tableCalc += [PSCustomObject]@{Calculation = "# TotCollateralETH   = OldcollateralETH     +   NewCollateralETH"}
$tableCalc += [PSCustomObject]@{Calculation = "# TotCollateralUSD   = TotCollateralETH     *   oracleprice[i1]   "}     
$tableCalc += [PSCustomObject]@{Calculation = "# Leverage           = TotCollateralETH     /   StartCollateralETH"} 
$tableCalc += [PSCustomObject]@{Calculation = "# OldcollateralETH   = TotCollateralETH"}
$tableCalc += [PSCustomObject]@{Calculation = "# CollLoanRatio      = TotCollateralUSD     /   TotCreditUSD"}
$tableCalc += [PSCustomObject]@{Calculation = "# LoanColl           = TotCreditUSD         /   TotCollateralUSD"}
$tableCalc += [PSCustomObject]@{Calculation = "# NetRevenueUSD      = TotCollateralUSD     -   TotCreditUSD         +  TotKeet10pctUSD"}
$tableCalc += [PSCustomObject]@{Calculation = "# BreakEven          = (StartCollateralUSD  +   StartCreditUSD)      /  StartCollateralETH"} 
$tableCalc += [PSCustomObject]@{Calculation = "# LiquidPreisMaxMint = OraclePriceTable[i1] +   LiquidationRatio"}
$tableCalc += [PSCustomObject]@{Calculation = "# EndLiquidPriceUSD  = ((TotCreditUSD       /   TotCollateralUSD)    /  MaxUsdMinting) * LiquidPreisMaxMint"}
$tableCalc += [PSCustomObject]@{Calculation = "# StartSoftLiquidUSD = EndLiquidPriceUSD    /   LiquidationRatio"}
$tableCalc += [PSCustomObject]@{Calculation = "# leverageEfficiency = ((TotCollateralETH   -   OldcollateralETH)      / OldcollateralETH)*100"} 
$tableCalc += [PSCustomObject]@{Calculation = "# LiquidPreisMax     = OraclePriceTable[i1] *   LiquidationRatio"}
$tableCalc += [PSCustomObject]@{Calculation = "# Differenz          = LoanCollRatio        /   MaxUsdMinting"}
$tableCalc += [PSCustomObject]@{Calculation = "# EndLiquidPriceUSD  = LiquidPreisMax       *   Differenz"}
$tableCalc += [PSCustomObject]@{Calculation = "# Differenz          = LoanCollRatio        /   MaxUsdMinting"}
$tableCalc += [PSCustomObject]@{Calculation = "# EndLiquidPriceUSD  = LiquidPreisMax       *   Differenz"}
$tableCalc += [PSCustomObject]@{Calculation = "# StartSoftLiquidUSD = EndLiquidPriceUSD    /  LiquidationRatio"}
              


# Create a custom table header

if ($TestLeverageEfficiency -eq "Y") {
    $header = "TotLoop","LoopNormInter","OldcollateralETH","OraclePrice","OldCollateralUSD","NewCreditUSD","TotCreditUSD","TotCollateralETH","leverageEfficiency"
}
elseif ($TestVaultSafetyUSD     -eq "Y") {
    $header = "TotLoop","LoopNormInter","OldcollateralETH","OraclePrice","OldCollateralUSD","NewCreditUSD","NewKeet10pctUSD", "NewCollateralETH", "TotCollateralETH","TotCollateralUSD", "TotCreditUSD","TotKeet10pctUSD"
}
elseif ($TestSaftyPriceDistance -eq "Y") {
    $header = "TotLoop","LoopNormInter","OldcollateralETH","OraclePrice","MaxCollUSDwSaftyPrice","OldCollateralUSD","NewCreditUSD","NewCollateralETH","TotCollateralETH","TotCollateralUSD", "TotCreditUSD"
}
elseif ($TestSoftLiquidPriceRange -eq "Y") {
    $header = "TotLoop","LoopNormInter",<#"OldcollateralETH","OraclePrice","OldCollateralUSD","TotCollateralETH","TotCollateralUSD",#> "StartSoftLiquidUSD","EndLiquidPriceUSD","LoanCollRatio"#,"LiquidPreisMaxMint"
}
else {
$header = 
"TotLoop",
"LoopNormInter",
"OldcollateralETH",
"OraclePrice",
"OldCollateralUSD",
"NewCreditUSD",
# "NewKeet10pctUSD", 
# "NewCollateralETH",
"TotCollateralETH",
"TotCollateralUSD", 
# "TotCreditUSD",
"NetRevenueUSD",
# "TotKeet10pctUSD",
"Leverage",
"StartSoftLiquidUSD",
"EndLiquidPriceUSD",
"LiquidPreisMaxMint",
"CollLoanRatio",
"leverageEfficiency"
"LoanCollRatio",
# "MaxCollUSDwSaftyPrice",
# "MaxCollUSD",
"ParKey"
}

#-------------------------------------------------------
# Functions
#-------------------------------------------------------
function GetMaxMintAndLiquidationPriceCalculation {
    Param ([int]$Bänder)
    $data = @'
Bänder	MaxMinbar	Liquidationpreisberechnung
4	0.8859	0.96059601
5	0.8815	0.95099005
6	0.8771	0.941480149
7	0.8727	0.932065348
8	0.8684	0.922744694
9	0.8641	0.913517247
10	0.8599	0.904382075
11	0.8556	0.895338254
12	0.8514	0.886384872
13	0.8473	0.877521023
14	0.8431	0.868745813
15	0.839	0.860058355
16	0.8349	0.851457771
17	0.8308	0.842943193
18	0.8268	0.834513761
19	0.8228	0.826168624
20	0.8189	0.817906938
21	0.8148	0.809727868
22	0.8109	0.80163059
23	0.8069	0.793614284
24	0.8031	0.785678141
25	0.7992	0.777821359
26	0.7983	0.770043146
27	0.7945	0.762342714
28	0.7907	0.754719287
29	0.7869	0.747172094
30	0.7832	0.739700373
31	0.7794	0.73230337
32	0.7757	0.724980336
33	0.7721	0.717730533
34	0.7684	0.710553227
35	0.7619	0.703447695
36	0.7612	0.696413218
37	0.7576	0.689449086
38	0.754	0.682554595
39	0.7505	0.675729049
40	0.747	0.668971759
41	0.7435	0.662282041
42	0.74	0.655659221
43	0.7366	0.649102628
44	0.7331	0.642611602
45	0.727	0.636185486
46	0.7264	0.629823631
47	0.723	0.623525395
48	0.7197	0.617290141
49	0.7164	0.61111724
50	0.7104	0.605006067

'@

    # Convert the data into a custom object
    $table  = $data  | ConvertFrom-Csv -Delimiter "`t" -Header 'Bänder', 'MaxMinbar', 'Liquidationpreisberechnung'

    # Query the table
    $result = $table | Where-Object { $_.Bänder -eq $Bänder } | Select-Object -Property MaxMinbar, Liquidationpreisberechnung
    
    Return $result
}


#-----------------------------------------------------------
# Future OraclePrice definition
# ----------------------------------------------------------
function SetFuturePriceSimulation {
    Param ( [string]$ParPriceVariant,
             [array]$ParFuturePricesInit,
               [int]$ParStartPrice,
               [int]$ParOraclePriceIncreasePct, 
               [int]$ParOraclePriceIncreaseAbs, 
               [int]$ParOraclePriceLimit 
    )
    
    # Veriant 1 - fix prices increase
    if ($ParPriceVariant -eq "fix") {
        $FuturePrices = $ParFuturePricesInit       
    }

    # Veriant 2 - prices increase by number of percentage %
    if ($ParPriceVariant -eq "pct") {    

        # $NumberOfPrices = $ParFuturePricesInit.Count
        $growthRate     = ($ParOraclePriceIncreasePct /100) +1 

        $FuturePrices = @($ParStartPrice)
        $m1 = 0
        while ($FuturePrices[$m1] -le $ParOraclePriceLimit) {
            $previousElement = $FuturePrices[$m1]
            $nextElement     = $previousElement * $growthRate
            $FuturePrices   += $nextElement
            $m1++
        }        
    }

    # Veriant 3 - fix prices increase
    if ($ParPriceVariant -eq "inc") {

        $FuturePrices = @($ParStartPrice)
        $m1 = 0
        while ($FuturePrices[$m1] -le $ParOraclePriceLimit) {
            $previousElement = $FuturePrices[$m1]
            $nextElement     = $previousElement + $ParOraclePriceIncreaseAbs
            $FuturePrices   += $nextElement
            $m1++
        }
    }
    Return $FuturePrices
}


#-----------------------------------------------------------
# Preparation
#-----------------------------------------------------------

$OraclePriceTable   = @()
$OraclePriceTable   = SetFuturePriceSimulation -ParPriceVariant $ParPriceVariant -ParStartPrice $StartPrice -ParOraclePriceLimit $ParOraclePriceLimit -ParOraclePriceIncreaseAbs $ParOraclePriceIncreaseAbs -ParOraclePriceIncreasePct $ParOraclePriceIncreasePct -ParFuturePricesInit $ParFuturePricesInit
$result             = GetMaxMintAndLiquidationPriceCalculation -Bänder $ParBänder
$MaxUsdMinting      = $($result.MaxMinbar)
$LiquidationRatio   = $($result.Liquidationpreisberechnung)

$tableCalc += [PSCustomObject]@{Calculation = "#--------------------------------------------------------------------------------------------------"}
$tableCalc += [PSCustomObject]@{Calculation = "# Settings"}
$tableCalc += [PSCustomObject]@{Calculation = "#--------------------------------------------------------------------------------------------------"}
$tableCalc += [PSCustomObject]@{Calculation = "# OutputFilePath         = $OutputFilePath"}
$tableCalc += [PSCustomObject]@{Calculation = "# StartCollateralETH     = $StartCollateralETH"}
$tableCalc += [PSCustomObject]@{Calculation = "# Bänder                 = $ParBänder"}
$tableCalc += [PSCustomObject]@{Calculation = "# MaxUsdMinting          = $MaxUsdMinting"}
$tableCalc += [PSCustomObject]@{Calculation = "# LiquidationRatio       = $LiquidationRatio"}
$tableCalc += [PSCustomObject]@{Calculation = "# LiquidPreisMaxMint     = $LiquidPreisMax "}
$tableCalc += [PSCustomObject]@{Calculation = ""}
$tableCalc += [PSCustomObject]@{Calculation = "# PriceVariant           = $ParPriceVariant"}
$tableCalc += [PSCustomObject]@{Calculation = "# OraclePrices           = $OraclePriceTable"}
$tableCalc += [PSCustomObject]@{Calculation = "# VaultSafetyUSD         = $ParVaultSafetyUSD %"}
$tableCalc += [PSCustomObject]@{Calculation = "# SaftyPriceDistancePct  = $ParSaftyPriceDistancePct %"}
$tableCalc += [PSCustomObject]@{Calculation = "# leverageEfficiency     = $ParleverageEfficiency %"}    
$tableCalc += [PSCustomObject]@{Calculation = ""}

if ($ParPriceVariant -eq "pct") {
    $tableCalc += [PSCustomObject]@{Calculation = "# OraclePriceIncreasePct = $ParOraclePriceIncreasePct %"}
    $tableCalc += [PSCustomObject]@{Calculation = "# OraclePriceLimit       = $ParOraclePriceLimit"}
}
if ($ParPriceVariant -eq "inc") {
    $tableCalc += [PSCustomObject]@{Calculation = "# OraclePriceIncreaseAbs = $ParOraclePriceIncreaseAbs"}
    $tableCalc += [PSCustomObject]@{Calculation = "# OraclePriceLimit       = $ParOraclePriceLimit"}
}
$tableCalc += [PSCustomObject]@{Calculation = ""}
$tableCalc += [PSCustomObject]@{Calculation = "# TestVaultSafetyUSD       : Test activ = $TestVaultSafetyUSD"}
$tableCalc += [PSCustomObject]@{Calculation = "# TestLeverageEfficiency   : Test activ = $TestLeverageEfficiency"}
$tableCalc += [PSCustomObject]@{Calculation = "# TestSoftLiquidPriceRange : Test activ = $TestSoftLiquidPriceRange"}


$tableRows = @()
$i2 = $OraclePriceTable.Count
$TotCollateralETH   = $StartCollateralETH

#-----------------------------------------------------------
# Main
#-----------------------------------------------------------
$i1=0
$i9=0 
$ii1=0

# Loop 1 : Price Changes
for ($i1 = 0; $i1 -lt $i2; $i1++) {       

    $OldcollateralETH   = $TotCollateralETH
    $OldCollateralUSD   = $OldcollateralETH     * $OraclePriceTable[$i1] 
    $TotCollateralUSD   = $TotCollateralETH     * $OraclePriceTable[$i1]        
    $NewCreditUSD       = (($OldcollateralETH  * $OraclePriceTable[$i1])* $MaxUsdMinting) - $TotCreditUSD   # AHA
    $TotCreditUSD      += $NewCreditUSD
    $NewKeet10pctUSD    = $NewCreditUSD         * ($ParVaultSafetyUSD      /100) # 10% Sicherheit
    $TotKeet10pctUSD   += $NewKeet10pctUSD  
    $NewCollateralETH   = ($NewCreditUSD        - $NewKeet10pctUSD)     / $OraclePriceTable[$i1]
    $TotCollateralETH   = $OldcollateralETH     + $NewCollateralETH
    $TotCollateralUSD   = $TotCollateralETH     * $OraclePriceTable[$i1]       
    $Leverage           = $TotCollateralETH     / $StartCollateralETH 
    $CollLoanRatio      = $TotCollateralUSD     / $TotCreditUSD
    $LoanCollRatio      = $TotCreditUSD         / $TotCollateralUSD
    $NetRevenueUSD      = $TotCollateralUSD     - $TotCreditUSD         + $TotKeet10pctUSD

    $LiquidPreisMax     = $OraclePriceTable[$i1] * $LiquidationRatio
    $Differenz          = $LoanCollRatio        / $MaxUsdMinting

    $EndLiquidPriceUSD  = $LiquidPreisMax       * $Differenz
    $StartSoftLiquidUSD = $EndLiquidPriceUSD    / $LiquidationRatio
           

    # $leverageEfficiency = (($TotCollateralETH - $OldcollateralETH) / $OldcollateralETH)*100 
    $leverageEfficiency = ( 100 / $OldcollateralETH * $TotCollateralETH) -100
    if ($leverageEfficiency -le $ParleverageEfficiency) {
        break  # This will exit the loop when the condition is met
    }
    $leverageEfficiencyPct = $leverageEfficiency/100
    $MaxCollUSDwSaftyPriceDist = ($TotCollateralETH * ($OraclePriceTable[$i1] * $ParSaftyPriceDistanceDecimal)) * $MaxUsdMinting
    $MaxCollUSD                = ($TotCollateralETH * ($OraclePriceTable[$i1] )                               ) * $MaxUsdMinting
        
    $tableRows += [PSCustomObject]@{
        TotLoop             = $i9++
        LoopNormInter       =  (($i1 *100+100))
        TotCollateralETH    = "{0,16:N2}" -f $TotCollateralETH
        OldcollateralETH    = "{0,16:N2}" -f $OldcollateralETH
        OldCollateralUSD    = "{0,16:N0}" -f $OldCollateralUSD
        TotCollateralUSD    = "{0,16:N0}" -f $TotCollateralUSD
        NewCreditUSD        = "{0,12:N0}" -f $NewCreditUSD
        NewCollateralETH    = "{0,16:N2}" -f $NewCollateralETH
        TotCreditUSD        = "{0,12:N0}" -f $TotCreditUSD
        NetRevenueUSD       = "{0,11:N0}" -f $NetRevenueUSD
        NewKeet10pctUSD     = "{0,15:N0}" -f $NewKeet10pctUSD
        TotKeet10pctUSD     = "{0,15:N0}" -f $TotKeet10pctUSD
        OraclePrice         = "{0,11:N0}" -f $OraclePriceTable[$i1]
        Leverage            = "{0,08:N1}" -f $Leverage
        CollLoanRatio       = "{0,12:P0}" -f $CollLoanRatio 
        LoanCollRatio       = "{0,13:P0}" -f $LoanCollRatio
        LiquidPreisMaxMint  = "{0,18:N0}" -f $LiquidPreisMax 
        EndLiquidPriceUSD   = "{0,17:N0}" -f $EndLiquidPriceUSD  
        StartSoftLiquidUSD  = "{0,18:N0}" -f $StartSoftLiquidUSD 
        leverageEfficiency  = "{0,18:P1}" -f $leverageEfficiencyPct 
        MaxCollUSDwSaftyPrice = "{0,21:N0}" -f $MaxCollUSDwSaftyPriceDist
        MaxCollUSD          = "{0,10:N0}" -f $MaxCollUSD 
        ParKey              =                $ParKey
        
    }
    # $NewCollateralETH=0


    # Loop 2 "Interloop" :  Loop until CollateralUSD is greater than TotCreditUSD
    # $ii1=0
    while (( $TotCreditUSD -lt (($TotCollateralETH * ($OraclePriceTable[$i1] * $ParSaftyPriceDistanceDecimal)) * $MaxUsdMinting)) -and $leverageEfficiency -ge $ParleverageEfficiency) 
    {
        
            $ii1++ 
            $OldcollateralETH   = $TotCollateralETH
            $OldCollateralUSD   = $OldcollateralETH *   $OraclePriceTable[$i1]       
            $TotCollateralUSD   = $TotCollateralETH *   $OraclePriceTable[$i1] 
            #$NewCreditUSD       = ($TotCollateralUSD -   $TotCreditUSD) #* $MaxUsdMinting
            $NewCreditUSD       = ($TotCollateralUSD * $MaxUsdMinting) -   $TotCreditUSD    # AHA                        
            $NewKeet10pctUSD    = $NewCreditUSD     *   ($ParVaultSafetyUSD/100)     # 10% Sicherheit
            $TotKeet10pctUSD    = $TotKeet10pctUSD  +   $NewKeet10pctUSD  
            $NewCollateralETH   = ($NewCreditUSD    -   $NewKeet10pctUSD) / $OraclePriceTable[$i1]
            $TotCreditUSD       = $TotCreditUSD     +   $NewCreditUSD
            $TotCollateralETH   = $OldcollateralETH +   $NewCollateralETH
            $TotCollateralUSD   = $TotCollateralETH *   $OraclePriceTable[$i1]        
            $Leverage           = $TotCollateralETH /   $StartCollateralETH 
            $CollLoanRatio      = $TotCollateralUSD /   $TotCreditUSD
            $LoanCollRatio      = $TotCreditUSD     /   $TotCollateralUSD
            $NetRevenueUSD      = $TotCollateralUSD -   $TotCreditUSD + $TotKeet10pctUSD
            $LiquidPreisMax     = $OraclePriceTable[$i1] * $LiquidationRatio
            $Differenz          = $LoanCollRatio        / $MaxUsdMinting        
            $EndLiquidPriceUSD  = $LiquidPreisMax       * $Differenz  
            $StartSoftLiquidUSD = $EndLiquidPriceUSD    / $LiquidationRatio


            # $leverageEfficiency = (($TotCollateralETH - $OldcollateralETH) / $OldcollateralETH)*100
            $leverageEfficiency = ( 100 / $OldcollateralETH * $TotCollateralETH) -100
            $leverageEfficiencyPct = $leverageEfficiency/100 
            $MaxCollUSDwSaftyPriceDist = ($TotCollateralETH * ($OraclePriceTable[$i1] * $ParSaftyPriceDistanceDecimal)) * $MaxUsdMinting
            $MaxCollUSD                = ($TotCollateralETH * ($OraclePriceTable[$i1] )                               ) * $MaxUsdMinting
            
            # Add the current values as a row in the table
            $tableRows += [PSCustomObject]@{
                TotLoop             = $i9++
                LoopNormInter       = "{0,05:N0}" -f ($ii1)
                TotCollateralETH    = "{0,16:N2}" -f $TotCollateralETH
                OldcollateralETH    = "{0,16:N2}" -f $OldcollateralETH
                OldCollateralUSD    = "{0,16:N0}" -f $OldCollateralUSD
                TotCollateralUSD    = "{0,16:N0}" -f $TotCollateralUSD
                NewCreditUSD        = "{0,12:N0}" -f $NewCreditUSD
                NewCollateralETH    = "{0,16:N2}" -f $NewCollateralETH
                TotCreditUSD        = "{0,12:N0}" -f $TotCreditUSD
                NetRevenueUSD       = "{0,11:N0}" -f $NetRevenueUSD
                NewKeet10pctUSD     = "{0,15:N0}" -f $NewKeet10pctUSD
                TotKeet10pctUSD     = "{0,15:N0}" -f $TotKeet10pctUSD
                OraclePrice         = "{0,11:N0}" -f $OraclePriceTable[$i1]
                Leverage            = "{0,08:N1}" -f $Leverage
                CollLoanRatio       = "{0,12:P0}" -f $CollLoanRatio 
                LoanCollRatio       = "{0,13:P0}" -f $LoanCollRatio
                LiquidPreisMaxMint  = "{0,18:N0}" -f $LiquidPreisMax 
                EndLiquidPriceUSD   = "{0,17:N0}" -f $EndLiquidPriceUSD  
                StartSoftLiquidUSD  = "{0,18:N0}" -f $StartSoftLiquidUSD 
                leverageEfficiency  = "{0,18:P1}" -f $leverageEfficiencyPct 
                MaxCollUSDwSaftyPrice = "{0,21:N0}" -f $MaxCollUSDwSaftyPriceDist
                MaxCollUSD          = "{0,10:N0}" -f $MaxCollUSD
                ParKey              =                $ParKey
            }
            $NewCollateralETH=0
    }
}

# Print out all Calulations / Formulas
$tableCalc | Format-Table -AutoSize

# Display the table with headers and lines between columns
$tableRows | Format-Table -Property $header -AutoSize | Out-String -Width 10000

$PathAndFilename = "$($OutputFilePath)\Output_$($ParPriceVariant)_$($Suffix).xlsx"

# If the file already exists, read its content
$existingData = @()
if (Test-Path $PathAndFilename) {
    $existingData = Import-Excel -Path $PathAndFilename -WorksheetName 'Sheet1' -NoHeader
}

# # Combine existing data with new data
# $combinedData = $existingData + $excelData

# # Write combined data to Excel
# $combinedData | Export-Excel -Path $PathAndFilename -WorksheetName 'Sheet1' -AutoSize -ClearSheet


if ($TestLeverageEfficiency -eq "Y") {
        Write-Host "## LeverageEfficency below benchmark :"
        Write-Host "## -> leverageEfficiency <= Benchmark = true "
        Write-Host "## --> Effectiv-LeverageEfficiency = $leverageEfficiency | Benchmark = $ParleverageEfficiency"
        Write-Host #empty line
}
if ($TestSaftyPriceDistance -eq "Y") {
    Write-Host "## SaftyPriceDistance to Oracle is : $ParSaftyPriceDistancePct and max Loan-Collateral Ratio is : $LoanColl"
}
Write-Host #empty line

if ($TestSoftLiquidPriceRange -eq "Y") {
    Write-Host "## SoftLiquidations starts at : $StartSoftLiquidUSD and ends at $EndLiquidPriceUSD "
}
Write-Host #empty line
