# Andrew Rucks
# 3/26/26
# For CIT241 - Systems Programming
# GET WEATHER USING API

function Main ()
{
    # get API key from user to avoid baking it into the code
    $apikey = Read-Host -Prompt "Enter your OpenWeatherMap API key"

    Get-Weather
}

function Get-Weather ()
{
    $city = Read-Host -Prompt "Enter the name of a U.S. city to get its weather report"
    $request = Invoke-RestMethod -Uri "api.openweathermap.org/data/2.5/weather?q=$($city),US&appid=$($apikey)" -ErrorAction Continue

    # if there is an error, clarify to the user.
    if ($? -EQ $false){echo "There has been an error; see the error message above. Try again?`n"}

    # print the weather data in a readable format
    Print-Weather $request

    # adds a delay to prevent accidental overload of API calls
    Start-Sleep 2

    # go again!
    Get-Weather
}

function Print-Weather ($data)
{
    if ($data -EQ $null){return}

    # print formatted weather data with unit conversions
    echo ""
    echo "`tSkies: $($data.weather.main)
    Temperature: $($data.main.temp - 273.15) C, feels like $($data.main.feels_like - 273.15) C
    Temp Range: $($data.main.temp_min - 273.15) - $($data.main.temp_max - 273.15) C
    Humidity: $($data.main.humidity)%
    Wind: $(($data.wind.speed * 3.6)) km/h from $($data.wind.deg) degrees"
}

Main