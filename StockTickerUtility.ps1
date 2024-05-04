<# Description: This script uses Polygon API to get basic stock info for the last 120 days.

resultsarray:
v*number
->The trading volume of the symbol in the given time period.
vwnumber
->The volume weighted average price.
o*number
->The opening price for the symbol in the given time period.
c*number
->The closing price for the symbol in the given time period.
h*number
->The highest price for the symbol in the given time period.
l*number
->The lowest price for the symbol in the given time period.
t*integer
->The Unix Msec timestamp for the start of the aggregate window.
ninteger
->The number of transactions in the aggregate window.
otcboolean
->Whether or not this aggregate is for an OTC ticker. This field will be left off if false.
#>


# MENU FUNCTIONS
function Show-Menu {
    param (
        [string]$Title = 'Stock Performance Utility v1.0'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "Check Stock's Performance for Past 120 Days" -ForegroundColor DarkYellow -BackgroundColor Black
    Write-Host "1: Press '1' to enter stock ticker." -ForegroundColor DarkGreen -BackgroundColor Black

    Write-Host "Q: Press 'Q' to quit."
}

# SCRIPT FUNCTIONS
function Get-StockInfo120 {
    # GENERAL VARIABLES
    $fromDate = (Get-Date).AddDays(-120).ToString('yyyy-MM-dd') #'2024-01-01'
    $currentDate = (Get-Date).ToString('yyyy-MM-dd') #'2024-05-01'
    $apiKey = 'apiKey=YOUR_POLYGON_API_KEY'
    # Enter stock ticker
    Write-Host "Let's see how the past 120 days have been for..." -ForegroundColor DarkGreen -BackgroundColor Black
    $stockTicker = Read-Host "Enter the desired stock ticker: "
    $multiplier = 1
    $timespan = 'day'
    $Uri = 'https://api.polygon.io/v2/aggs/ticker/'+$stockTicker+'/range/'+$multiplier+'/'+$timespan+'/'+$fromDate+'/'+$currentDate+'?adjusted=true&sort=asc&limit=120&'+$apiKey

    # Get the data
    $Result = Invoke-RestMethod -Uri $Uri 

    # Get the first and last open price
    $FirstOpen = $Result.results.o | Select-Object -First 1 
    $LastOpen = $Result.results.o | Select-Object -Last 1 

    # Get the average open price
    $Count = ($Result.results.o -Split ' ' | Measure-Object).Count
    $Sum = ($Result.results.o -Split ' ' | Measure-Object -Sum).Sum
    $Average = $Sum / $Count
    $AverageOpen = [math]::Round($Average,2)

    # Output the results
    Write-Output "The first opening price of $stocksTicker in this series was $FirstOpen"  
    Write-Output "The last opening price of $stocksTicker in this series was $LastOpen"
    Write-Output "The average opening price of $stocksTicker in this series was $AverageOpen"

    # Calculate the percentage of change
    $Subtracted = $LastOpen - $FirstOpen
    $Divided = $Subtracted / $FirstOpen
    $Percentage = $Divided * 100
    $Change = [math]::Round($Percentage,2)

    # Display the percentage of change
    If ($FirstOpen -gt $LastOpen) {
        Write-Output "The stock price has decreased by $Change %"
    }
    Else {
        Write-Output "The stock price has increased by $Change %"
    }
}

# EXECUTE INTERACTIVE MENU
do {
    Show-Menu
    $selection = Read-Host "Please make a selection"
    switch ($selection) {
        # CALL FUNCTIONS
        '1' {
            'Getting Stock Information for the last 120 days...'
            Get-StockInfo120
        }
    }
    pause
}
until (
    $selection -eq 'q'
)
