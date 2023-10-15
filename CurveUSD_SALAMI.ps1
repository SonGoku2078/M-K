
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
$LoanColl           = 0
$OraclePriceTable   = @()

#-------------------------------------------------------
# Statistics & prints
#-------------------------------------------------------

# print: variables & calculation
$Global:tableCalc=@()
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
$tableCalc += [PSCustomObject]@{Calculation = ""}


# Create a custom table header
$header = "Loop",` 
"OldcollateralETH","OraclePrice","OldCollateralUSD",`
"NewCreditUSD","NewKeet10pctUSD", "NewCollateralETH",`
"TotCollateralETH","TotCollateralUSD", "TotCreditUSD",`
"NetRevenueUSD","TotKeet10pctUSD","Leverage",`
"StartSoftLiquidUSD","EndLiquidPriceUSD","LiquidPreisMaxMint",`
"CollLoanRatio","LoanColl"


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
    $table = $data | ConvertFrom-Csv -Delimiter "`t" -Header 'Bänder', 'MaxMinbar', 'Liquidationpreisberechnung'
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
# Settings
#-----------------------------------------------------------

$OutputFilePath             = "C:\Users\SonGoku78\Downloads\"

$StartCollateralETH         = 5
$Bänder                     = 4
$VaultSafetyUSD             = 10       # 10% Sicherheit 
$SaftyPriceDistancePct      = 0.8      # min gap to oracle price eg. if a gap 25% then enter 0.75
$StartPrice                 = 1550.43

$ParPriceVariant            = "fix" #fix | pct | inc


#"fix"
$FuturePricesInit           = @($StartPrice, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000)        

#"pct" $StartPrice will be taken and the number of % 
$ParOraclePriceIncreasePct  = 50
$ParOraclePriceLimit        = 10000

#"inc"
$ParOraclePriceIncreaseAbs  = 500
$ParOraclePriceLimit        = 10000

$OraclePriceTable           = SetFuturePriceSimulation -ParPriceVariant $ParPriceVariant -ParStartPrice $StartPrice -ParOraclePriceLimit $ParOraclePriceLimit -ParOraclePriceIncreaseAbs $ParOraclePriceIncreaseAbs -ParOraclePriceIncreasePct $ParOraclePriceIncreasePct -ParFuturePricesInit $FuturePricesInit


#-----------------------------------------------------------
# Prep
#-----------------------------------------------------------

$result = GetMaxMintAndLiquidationPriceCalculation -Bänder $Bänder
$MaxUsdMinting      =  $($result.MaxMinbar)
$LiquidationRatio   =  $($result.Liquidationpreisberechnung)

$tableCalc += [PSCustomObject]@{Calculation = "#--------------------------------------------------------------------------------------------------"}
$tableCalc += [PSCustomObject]@{Calculation = "# Settings"}
$tableCalc += [PSCustomObject]@{Calculation = "#--------------------------------------------------------------------------------------------------"}
$tableCalc += [PSCustomObject]@{Calculation = "# OutputFilePath         = $OutputFilePath"}
$tableCalc += [PSCustomObject]@{Calculation = "# Bänder                 = $Bänder"}
$tableCalc += [PSCustomObject]@{Calculation = "# MaxUsdMinting          = $MaxUsdMinting"}
$tableCalc += [PSCustomObject]@{Calculation = "# LiquidationRatio       = $LiquidationRatio"}
$tableCalc += [PSCustomObject]@{Calculation = ""}
$tableCalc += [PSCustomObject]@{Calculation = "# ParPriceVariant        = $ParPriceVariant"}
$tableCalc += [PSCustomObject]@{Calculation = "# OraclePrices           = $OraclePriceTable"}
$tableCalc += [PSCustomObject]@{Calculation = "# VaultSafetyUSD         = $VaultSafetyUSD %"}
$temp = 100 - ($SaftyPriceDistancePct *100 ) 
$tableCalc += [PSCustomObject]@{Calculation = "# SaftyPriceDistancePct  = $temp %"}
$tableCalc += [PSCustomObject]@{Calculation = ""}

if ($ParPriceVariant -eq "pct") {
    $tableCalc += [PSCustomObject]@{Calculation = "# OraclePriceIncreasePct = $ParOraclePriceIncreasePct %"}
    $tableCalc += [PSCustomObject]@{Calculation = "# ParOraclePriceLimit    = $ParOraclePriceLimit"}
}
if ($ParPriceVariant -eq "inc") {
    $tableCalc += [PSCustomObject]@{Calculation = "# OraclePriceIncreaseAbs= $ParOraclePriceIncreaseAbs"}
    $tableCalc += [PSCustomObject]@{Calculation = "# OraclePriceLimit    = $ParOraclePriceLimit"}
}



$tableRows = @()
$i2 = $OraclePriceTable.Count
$TotCollateralETH   = $StartCollateralETH

#-----------------------------------------------------------
# Main
#-----------------------------------------------------------
$i1=0
$ii1=0
# $tableCalc += [PSCustomObject]@{Calculation = "# Break-Even       = (($StartCollateralETH * $OraclePriceTable[0]) + (($StartCollateralETH * $OraclePriceTable[0])  * $MaxUsdMinting)) / $StartCollateralETH "}


# Loop 1 : Price Changes
for ($i1 = 0; $i1 -lt $i2; $i1++) {       
    
    $OldcollateralETH   = $TotCollateralETH
    $OldCollateralUSD   = $OldcollateralETH     * $OraclePriceTable[$i1] 
    $TotCollateralUSD   = $TotCollateralETH     * $OraclePriceTable[$i1]        
    $NewCreditUSD       = ((($OldcollateralETH  * $OraclePriceTable[$i1])- $TotCreditUSD)   * $MaxUsdMinting)
    $TotCreditUSD      += $NewCreditUSD
    $NewKeet10pctUSD    = $NewCreditUSD         * ($VaultSafetyUSD      /100) # 10% Sicherheit
    $TotKeet10pctUSD   += $NewKeet10pctUSD  
    $NewCollateralETH   = ($NewCreditUSD        - $NewKeet10pctUSD)     / $OraclePriceTable[$i1]
    $TotCollateralETH   = $OldcollateralETH     + $NewCollateralETH
    $TotCollateralUSD   = $TotCollateralETH     * $OraclePriceTable[$i1]       
    $Leverage           = $TotCollateralETH     / $StartCollateralETH 
    $CollLoanRatio      = $TotCollateralUSD     / $TotCreditUSD
    $LoanColl           = $TotCreditUSD         / $TotCollateralUSD
    $NetRevenueUSD      = $TotCollateralUSD     - $TotCreditUSD         + $TotKeet10pctUSD
    $LiquidPreisMaxMint = $OraclePriceTable[$i1]+ $LiquidationRatio
    $EndLiquidPriceUSD  = (($TotCreditUSD       / $TotCollateralUSD)    / $MaxUsdMinting)   * $LiquidPreisMaxMint
    $StartSoftLiquidUSD = $EndLiquidPriceUSD    / $LiquidationRatio
    
    $tableRows += [PSCustomObject]@{
        Loop                = "{0,04:N0}"  -f (($i1 *10+10))
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
        LoanColl            = "{0,08:P0}" -f $LoanColl
        LiquidPreisMaxMint  = "{0,18:N0}" -f $LiquidPreisMaxMint 
        EndLiquidPriceUSD   = "{0,17:N0}" -f $EndLiquidPriceUSD  
        StartSoftLiquidUSD  = "{0,18:N0}" -f $StartSoftLiquidUSD 
    }
    # $NewCollateralETH=0
    

    # Loop 2 "Interloop" :  Loop until CollateralUSD is greater than TotCreditUSD
    # $ii1=0
    while ( $TotCreditUSD -lt (($TotCollateralETH * ($OraclePriceTable[$i1] * $SaftyPriceDistancePct)) * $MaxUsdMinting)) {
            $ii1++ 
            $OldcollateralETH   = $TotCollateralETH
            $OldCollateralUSD   = $OldcollateralETH *   $OraclePriceTable[$i1]       
            $TotCollateralUSD   = $TotCollateralETH *   $OraclePriceTable[$i1] 
            $NewCreditUSD       = ($TotCollateralUSD-   $TotCreditUSD) * $MaxUsdMinting    
            $NewKeet10pctUSD    = $NewCreditUSD     *   ($VaultSafetyUSD/100)     # 10% Sicherheit
            $TotKeet10pctUSD    = $TotKeet10pctUSD  +   $NewKeet10pctUSD  
            $NewCollateralETH   = ($NewCreditUSD    -   $NewKeet10pctUSD) / $OraclePriceTable[$i1]
            $TotCreditUSD       = $TotCreditUSD     +   $NewCreditUSD
            $TotCollateralETH   = $OldcollateralETH +   $NewCollateralETH
            $TotCollateralUSD   = $TotCollateralETH *   $OraclePriceTable[$i1]        
            $Leverage           = $TotCollateralETH /   $StartCollateralETH 
            $CollLoanRatio      = $TotCollateralUSD /   $TotCreditUSD
            $LoanColl           = $TotCreditUSD     /   $TotCollateralUSD
            $NetRevenueUSD      = $TotCollateralUSD -   $TotCreditUSD + $TotKeet10pctUSD
            $LiquidPreisMaxMint = $OraclePriceTable[$i1]+ $LiquidationRatio
            $EndLiquidPriceUSD  = (($TotCreditUSD       / $TotCollateralUSD)    / $MaxUsdMinting)   * $LiquidPreisMaxMint
            $StartSoftLiquidUSD = $EndLiquidPriceUSD    / $LiquidationRatio

            
            # Add the current values as a row in the table
            $tableRows += [PSCustomObject]@{
                Loop                = "{0,04:N0}" -f ($ii1)
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
                LoanColl            = "{0,08:P0}" -f $LoanColl
                LiquidPreisMaxMint  = "{0,18:N0}" -f $LiquidPreisMaxMint 
                EndLiquidPriceUSD   = "{0,17:N0}" -f $EndLiquidPriceUSD  
                StartSoftLiquidUSD  = "{0,18:N0}" -f $StartSoftLiquidUSD 
            }
            $NewCollateralETH=0
    }
}

# Print out all Calulations / Formulas
$tableCalc | Format-Table -AutoSize

# Display the table with headers and lines between columns
$tableRows | Format-Table -Property $header -AutoSize | Out-String -Width 1000

# Display the table with headers and lines between columns and remove single quotes
$tableRows | Export-Csv -Path "$($ParPriceVariant)_output.csv" -Delimiter ";" -NoTypeInformation
(Get-Content "$($ParPriceVariant)_output.csv") | ForEach-Object { $_ -replace '"', '' -replace '\?', '' } | Set-Content "$($OutputFilePath)\Output_$($ParPriceVariant).csv"

