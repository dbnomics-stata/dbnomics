# dbnomics
Stata client for DB.nomics, the world's economic database (https://db.nomics.world)

## Description

dbnomics provides a suite of tools to browse and import time series data
from DB.nomics, the world's economic database (https://db.nomics.world).
DB.nomics is a web-based platform that aggregates and maintains time
series data from various statistical agencies across the world.  dbnomics
only works with Stata 14.0 or higher, since it relies on the secure HTTP
protocol (https).

dbnomics provides an interface to DB.nomics' RESTful API
(https://api.next.nomics.world/apidocs), allowing for the advanced
filtering of data using Stata's native options syntax (see Examples). To
achieve this, the command relies on Erik Lindsley's libjson backend (ssc
install libjson).

## Syntax

```Stata
. //Load list of providers
. dbnomics providers [, clear]

. //Load content tree for a given provider
. dbnomics tree , provider(PRcode) [clear]

. //Load dataset structure given a provider and dataset
. dbnomics datastructure , provider(PRcode) dataset(DScode) [clear nostat]

. // Load list of series for a given provider and dataset
. dbnomics series , provider(PRcode) dataset(DScode) [clear limit(int) dimensions_opt]

. // Import series for a given provider and dataset
. dbnomics import , provider(PRcode) dataset(DScode) [clear limit(int) seriesids(SERIES_list) sdmx(SDMX_mask) dimensions_opt]

. // Load one series via direct reference
. dbnomics use SERIES_code , provider(PRcode) dataset(DScode) [clear delimiter(char)]
```

## Options
### Main

**provider(**PRcode**)** sets the source that contains the data of interest. The
list of data providers is continuously updated by the DB.nomics team.
To obtain the most recent list of active data providers, use the
command **dbnomics providers [, clear]**.

**dataset(**DScode**)** sets the source dataset for the time series of interest.
A category tree containing all datasets associated with each
provider(*PRcode*) can be obtained via the command **dbnomics tree,
provider(PRcode) [clear]**. (**Note**: not all datasets available in the
category tree may be accessible).

**clear** clears data in memory before importing data from DB.nomics.

### datastructure 

**nostat** disables the parsing of series statistics. By default, the command
**dbnomics datastructure , (...)** also collects information on the
number of time series associated with each dataset dimension value.
Using the **nostat** option disables this additional parsing of data,
speeding up the loading process.

### series/import

**limit(**int**)** sets the maximum number of series to load. It limits the
number of series identified by the **dbnomics series** or **dbnomics import**
commands, resulting in faster download of information.  A Warning
message is issued if the total number of series identified is larger
than the inputted limit(int).

**dimensions_opt(**dim_values**)** are provider(*PRcode*)- and
dataset(*DScode*)-specific options that can be used to identify series.
A list of dimensions can be obtained using **dbnomics datastructure,
provider(PRcode) dataset(DScode)**.  For instance, assuming the
dimensions of dataset(*DScode*) to be *freq.unit.geo*, accepted options
for **dbnomics series,(...)** and **dbnomics import,(...)** are
**freq(**codelist**)**, **unit(**codelist**)** and **geo(**codelist**)**.  Each
**dimension_opt(**dim_values**)** can contain one or more values in a space
or comma-separated list, so as to select multiple dimensions at once
(*e.g.*, a list of countries).  **Note:** dbnomics does not carry a
validation check on user-inputted **dimension_opt(**dim_values**)**; if a
dimension_opt(dim_values) is invalid, dbnomics will likely return the
message Warning: no series found. See the Examples section.

### import

*Note:* the options below are mutually exclusive and are alternatives to
**dimensions_opt(**dim_values**)**.

**seriesids(**SERIES_list**)** accepts a comma-separated list of names
corresponding to series available in provider(*PRcode*) and
dataset(*DScode*). Each series is then imported accordingly.

**sdmx(**SDMX_mask**)** accepts an SDMX REST query ("SDMX mask") containing
dimensions to identify series for a provider(*PRcode*) and
dataset(*DScode*) that supports this function.  A list of dimensions
can be obtained using **dbnomics datastructure, provider(PRcode)
dataset(DScode)**. **Note**: not all providers will support this feature.
In such case **dbnomics import, (...)** may return a Warning: no series
found error.

### use

**delimiters(**"chars"[, collapse|asstring]**)** allows to specify other
separation characters.  By default, **dbnomics use ...**  will assume
tab-separated data.  This option is generally not needed but accounts
for potential future changes in the series specification of
https://db.nomics.world.

## Remarks

This program has two main dependencies:

1) The Mata json library libjson by Erik Lindsley is needed to parse JSON
strings. It can be found on SSC: `ssc install libjson`.
2) The routine moss by Robert Picard & Nicholas J. Cox is needed to clean
unicode sequences. It can be found on SSC: `ssc install moss`.

After each API call, dbnomics stores significant metadata in the form of
dataset characteristics.  Type *char li _dta[]* after dbnomics to obtain
important info about the data, e.g., the API endpoint.

## Examples

```Stata
. // Load the list of available providers with additional metadata:

. dbnomics providers, clear

. // Load the dataset tree of of the AMECO provider:
. dbnomics tree, provider(AMECO) clear

. // Analyse the structure of dataset PIGOT for provider AMECO:
. dbnomics datastructure, provider(AMECO) dataset(PIGOT) clear
Price deflator gross fixed capital formation: other investment
86 series found. Order of dimensions: (freq.unit.geo)

. // List all series in AMECO/PIGOT containing deflators in national currency:
. dbnomics series, provider(AMECO) dataset(PIGOT) unit(national-currency-2010-100) clear
40 of 86 series selected. Order of dimensions: (freq.unit.geo)

. // Import all series in AMECO/PIGOT containing deflators in national currency:
. dbnomics import, provider(AMECO) dataset(PIGOT) unit(national-currency-2010-100) clear
........................................
40 series found and imported

. // Import single AMECO/PIGOT series:
. dbnomics import, pr(AMECO) d(PIGOT) seriesids(ESP.3.1.0.0.PIGOT,SVN.3.1.0.0.PIGOT,LVA.3.1.99.0.PIGOT) clear
...
3 series found and imported

. // Load one AMECO/PIGOT series:
. dbnomics use SVN.3.1.0.0.PIGOT, pr(AMECO) d(PIGOT) clear
(2 vars, 60 obs)

. // Eurostat typically supports SMDX queries
Import all series in Eurostat/ei_bsin_m related to Belgium:
. dbnomics import, provider(Eurostat) dataset(ei_bsin_m) geo(BE) clear
................
16 series found and imported

. // Do the same using sdmx:
. dbnomics import, provider(Eurostat) dataset(ei_bsin_m) sdmx(M.BAL...BE) clear
................
16 series found and imported
```

## Stored results

dbnomics stores the following in r():

Local     
endpoint       name of dbnomics subcommand

## Author

Simone Signore (signoresimone at yahoo [dot] it)
