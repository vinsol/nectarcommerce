# Worldly
Elixir Module containing data about Countries and their states

**Warning** 

Alpha Quality(Work in Progress). Reads the files for every function call.

**TODO**

1. Improve performance by utilizing the OTP.
2. Add proper localization support.
3. Publish to Hex.

## Installation

  1. Add worldly to your list of dependencies in `mix.exs`. use the github link for now.

  2. Ensure worldly is started before your application:

        def application do
          [applications: [:worldly]]
        end

## Usage
   1. To get the list of countries use `Worldly.Country.all`
   2. You can get country by code using `Worldly.Country.with_code alpha_2_code`
   3. To get the regions for a country use `Worldly.Region.regions_for country`, where country is the country struct `Worldy.Country`